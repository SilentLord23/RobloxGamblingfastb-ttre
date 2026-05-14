// window.java
// Purpose: Swing-based front-end for the native slot machine logic.
// Notes:
//  - Expects an Assets/ directory with ETM_Background.png, 1.png .. 9.png, and FNHF.wav for music.
//  - The class uses slotLogic (JNI) to perform game actions; ensure the native library is available.
//  - All UI work must be done on the Swing Event Dispatch Thread (EDT). buildUI, runSpin, and
//    any code manipulating Swing components should be called on the EDT (SwingUtilities.invokeLater).
//  - Image loading and audio occur in loadResources/playMusic which currently run on the EDT; for
//    large assets consider loading them off the EDT and publishing results back to the UI thread.
//  - This implementation swallows exceptions for resource loading to avoid crashing the UI; consider
//    logging or reporting errors in a production application.

import javax.swing.*;
import java.awt.*;
import java.io.File;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.util.HashMap;
import java.util.Map;
import javax.sound.sampled.*;

public class window {
    // JNI wrapper for native slot engine
    private slotLogic logic = new slotLogic();
    // Grid of JLabels used to display the reel symbol icons (rows x cols: 3 x 5)
    private JLabel[][] reelLabels = new JLabel[3][5];
    // Displays result text such as "Win: $" or "No win"
    private JLabel resultLabel;
    // Background image drawn by the BackgroundPanel
    private BufferedImage backgroundImage;
    // Cache of scaled symbol icons keyed by symbol ID (1..9)
    private Map<Integer, ImageIcon> symbolIcons = new HashMap<>();
    // Timer used for automatic repeated spins
    private Timer autospinTimer;
    private boolean isAutospinning = false;
    private boolean isSpinning = false;
    private final int SYMBOL_SIZE = 160; // pixel size used when scaling symbol images
    // Background music clip (looped). Remember to close the clip on shutdown in a real app.
    private Clip bgMusic;

    class BackgroundPanel extends JPanel {
        @Override
        protected void paintComponent(Graphics g) {
            super.paintComponent(g);
            if (backgroundImage != null) {
                g.drawImage(backgroundImage, 0, 0, getWidth(), getHeight(), this);
            }
        }
    }

    public void buildUI(JFrame frame) {
        // Build and layout the Swing UI. This method should run on the EDT.
        loadResources(); // loads images synchronously; consider moving off-EDT for large assets
        playMusic("Assets/FNHF.wav"); // starts background music if available

        BackgroundPanel mainPanel = new BackgroundPanel();
        mainPanel.setLayout(new BorderLayout());
        frame.setContentPane(mainPanel);

        JPanel topPanel = new JPanel(new FlowLayout(FlowLayout.LEFT, 20, 10));
        topPanel.setOpaque(false);
        JLabel balanceLabel = new JLabel("Balance: ₹" + String.format("%.2f", logic.getBalance()));
        balanceLabel.setFont(new Font("Arial", Font.BOLD, 24));
        balanceLabel.setForeground(Color.WHITE);
        topPanel.add(balanceLabel);
        mainPanel.add(topPanel, BorderLayout.NORTH);

        JPanel centerWrapper = new JPanel(new GridBagLayout());
        centerWrapper.setOpaque(false);
        GridBagConstraints gbc = new GridBagConstraints();

        JPanel reelPanel = new JPanel(new GridLayout(3, 5, 0, 0));
        reelPanel.setOpaque(false);
        Dimension labelSize = new Dimension(SYMBOL_SIZE, SYMBOL_SIZE);
        
        for (int r = 0; r < 3; r++) {
            for (int c = 0; c < 5; c++) {
                reelLabels[r][c] = new JLabel("", SwingConstants.CENTER);
                reelLabels[r][c].setOpaque(true);
                reelLabels[r][c].setBackground(new Color(255, 255, 255, 180));
                reelLabels[r][c].setBorder(BorderFactory.createLineBorder(Color.BLACK, 1));
                reelLabels[r][c].setPreferredSize(labelSize);
                reelPanel.add(reelLabels[r][c]);
            }
        }
        
        gbc.gridx = 0;
        gbc.gridy = 0;
        centerWrapper.add(reelPanel, gbc);

        resultLabel = new JLabel(" ", SwingConstants.CENTER);
        resultLabel.setFont(new Font("Arial", Font.BOLD, 32));
        resultLabel.setForeground(Color.YELLOW);
        resultLabel.setPreferredSize(new Dimension(800, 60));
        
        gbc.gridy = 1;
        gbc.insets = new Insets(20, 0, 0, 0);
        centerWrapper.add(resultLabel, gbc);

        mainPanel.add(centerWrapper, BorderLayout.CENTER);

        JPanel footerPanel = new JPanel(new BorderLayout());
        footerPanel.setOpaque(false);

        JPanel controlPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 20, 10));
        controlPanel.setOpaque(false);

        JButton betButton = new JButton("Bet: ₹" + logic.getCurrentBet());
        betButton.setPreferredSize(new Dimension(150, 50));
        betButton.setFont(new Font("Arial", Font.BOLD, 18));

        JButton spinButton = new JButton("SPIN");
        spinButton.setPreferredSize(new Dimension(150, 50));
        spinButton.setFont(new Font("Arial", Font.BOLD, 18));

        JButton autospinButton = new JButton("AUTOSPIN");
        autospinButton.setPreferredSize(new Dimension(150, 50));
        autospinButton.setFont(new Font("Arial", Font.BOLD, 18));

        betButton.addActionListener(e -> {
            if (!isSpinning && !isAutospinning) {
                logic.nextBet();
                betButton.setText("Bet: ₹" + logic.getCurrentBet());
            }
        });

        spinButton.addActionListener(e -> {
            if (!isSpinning && !isAutospinning) runSpin(balanceLabel);
        });

        autospinTimer = new Timer(2500, e -> {
            if (!isSpinning) {
                if (logic.getBalance() >= logic.getCurrentBet()) {
                    runSpin(balanceLabel);
                } else {
                    stopAutospin(autospinButton);
                }
            }
        });

        autospinButton.addActionListener(e -> {
            if (!isAutospinning) startAutospin(autospinButton);
            else stopAutospin(autospinButton);
        });

        controlPanel.add(betButton);
        controlPanel.add(spinButton);
        
        JPanel rightPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT, 20, 10));
        rightPanel.setOpaque(false);
        rightPanel.add(autospinButton);

        footerPanel.add(controlPanel, BorderLayout.CENTER);
        footerPanel.add(rightPanel, BorderLayout.EAST);
        
        JPanel leftSpacer = new JPanel();
        leftSpacer.setPreferredSize(new Dimension(170, 50));
        leftSpacer.setOpaque(false);
        footerPanel.add(leftSpacer, BorderLayout.WEST);

        mainPanel.add(footerPanel, BorderLayout.SOUTH);
    }

    private void playMusic(String path) {
        try {
            // Load and loop background music. Failures are ignored to keep UI responsive.
            AudioInputStream stream = AudioSystem.getAudioInputStream(new File(path));
            bgMusic = AudioSystem.getClip();
            bgMusic.open(stream);
            bgMusic.loop(Clip.LOOP_CONTINUOUSLY);
            bgMusic.start();
        } catch (Exception e) {
            // In production, log or notify instead of silently swallowing exceptions.
        }
    }

    private void loadResources() {
        try {
            // Load background and symbols from Assets/. Images are scaled to SYMBOL_SIZE
            // and stored in symbolIcons for quick reuse when updating the UI.
            backgroundImage = ImageIO.read(new File("Assets/ETM_Background.png"));
            for (int i = 1; i <= 9; i++) {
                File imgFile = new File("Assets/" + i + ".png");
                if (imgFile.exists()) {
                    Image img = ImageIO.read(imgFile).getScaledInstance(SYMBOL_SIZE, SYMBOL_SIZE, Image.SCALE_SMOOTH);
                    symbolIcons.put(i, new ImageIcon(img));
                }
            }
        } catch (Exception e) {
            // Loading failure leaves symbolIcons possibly empty; UI code should handle missing icons gracefully.
        }
    }

    private void startAutospin(JButton button) {
        // Start automatic spinning using a Swing Timer. Timer callbacks run on the EDT.
        isAutospinning = true;
        button.setText("STOP");
        autospinTimer.start();
    }

    private void stopAutospin(JButton button) {
        // Stop automatic spinning and update the button label accordingly.
        isAutospinning = false;
        button.setText("AUTOSPIN");
        autospinTimer.stop();
    }

    private void runSpin(JLabel balanceLabel) {
        // Trigger a spin in the native logic, animate the reels using Swing Timers, and
        // update UI labels asynchronously via timers. This must run on the EDT.
        double win = logic.spin();
        if (win < 0) return;

        isSpinning = true;
        resultLabel.setText("Rolling...");
        int[][] board = logic.getLastBoard();

        for (int c = 0; c < 5; c++) {
            for (int r = 0; r < 3; r++) {
                final int row = r;
                final int col = c;
                int stopDelay = (c * 400) + (row * 100) + 800;

                Timer shuffleTimer = new Timer(70, null);
                shuffleTimer.addActionListener(e -> {
                    int randomId = (int) (Math.random() * 9) + 1;
                    reelLabels[row][col].setIcon(symbolIcons.get(randomId));
                });
                shuffleTimer.start();

                Timer stopTimer = new Timer(stopDelay, e -> {
                    shuffleTimer.stop();
                    reelLabels[row][col].setIcon(symbolIcons.get(board[row][col]));
                    if (row == 2 && col == 4) finishSpin(win, balanceLabel);
                });
                stopTimer.setRepeats(false);
                stopTimer.start();
            }
        }
    }

    private void finishSpin(double win, JLabel balanceLabel) {
        // Called when the last reel stops. Update result label and the displayed balance.
        isSpinning = false;
        if (win > 0) resultLabel.setText("Win: " + String.format("%.2f", win));
        else resultLabel.setText("No win");
        balanceLabel.setText("Balance: $" + String.format("%.2f", logic.getBalance()));
    }

    public static void main(String[] args) {
        // Launch the application on the Event Dispatch Thread (EDT). The native library
        // must be present so that logic.loadAssets() succeeds.
        SwingUtilities.invokeLater(() -> {
            window game = new window();
            JFrame frame = new JFrame("Edgar's Torture Machine");
            frame.setSize(1200, 800);
            frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
            if (game.logic.loadAssets()) {
                game.buildUI(frame);
                frame.setVisible(true);
            }
        });
    }
}