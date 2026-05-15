// window.java
// Swing front-end for the native slot machine. Responsible for building the UI, loading
// local assets (images, music), animating reels, and coordinating with the native slotLogic
// JNI wrapper for game state and actions.
// IMPORTANT:
//  - UI work must happen on the Swing Event Dispatch Thread (EDT). buildUI and all
//    Swing component updates should run on the EDT (use SwingUtilities.invokeLater).
//  - Currently image/audio loading runs on the EDT; for larger assets move loading off-EDT.
//  - The native library provides game state; this class treats it as the authoritative source
//    and only reads/writes via the slotLogic API.

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
    // Displays result text such as "Win:" or bonus status
    private JLabel resultLabel;
    // Background image drawn behind components
    private BufferedImage backgroundImage;
    // Cache of scaled symbol icons keyed by symbol ID (1..9, 10 == bonus)
    private Map<Integer, ImageIcon> symbolIcons = new HashMap<>();
    // Timer used for automatic repeated spins; callbacks run on the EDT
    private Timer autospinTimer;
    private boolean isAutospinning = false;
    private boolean isSpinning = false;
    private final int SYMBOL_SIZE = 160;
    // Background music clip (looped). In a real app, close the clip on shutdown.
    private Clip bgMusic;

    class BackgroundPanel extends JPanel {
        @Override
        protected void paintComponent(Graphics g) {
            super.paintComponent(g);
            // Draw background image scaled to panel size when available
            if (backgroundImage != null) {
                g.drawImage(backgroundImage, 0, 0, getWidth(), getHeight(), this);
            }
        }
    }

    public void buildUI(JFrame frame) {
        // Build UI on the EDT. Loads resources (images, audio) synchronously here;
        // consider offloading if assets are large or loading is slow.
        loadResources();
        playMusic("Assets/FNHF.wav");

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
        /*
        JButton debugBonusButton = new JButton("DEBUG: BONUS");
        debugBonusButton.setPreferredSize(new Dimension(150, 50));
        debugBonusButton.setFont(new Font("Arial", Font.PLAIN, 12));
        debugBonusButton.setBackground(Color.DARK_GRAY);
        debugBonusButton.setForeground(Color.WHITE);
        */
        betButton.addActionListener(e -> {
            if (!isSpinning && !isAutospinning && !logic.isBonusActive()) {
                logic.nextBet();
                betButton.setText("Bet: ₹" + logic.getCurrentBet());
            }
        });

        spinButton.addActionListener(e -> {
            if (!isSpinning && !isAutospinning && !logic.isBonusActive()) runSpin(balanceLabel);
        });
        /*
        debugBonusButton.addActionListener(e -> {
            if (!isSpinning && !isAutospinning && !logic.isBonusActive()) {
                logic.forceBonus();
                runSpin(balanceLabel);
            }
        });
        */
        autospinTimer = new Timer(2500, e -> {
            if (!isSpinning && !logic.isBonusActive()) {
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
        controlPanel.add(autospinButton);
        
        JPanel rightPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT, 20, 10));
        rightPanel.setOpaque(false);
        // rightPanel.add(debugBonusButton);

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
            // Load and loop background music; exceptions are currently swallowed to keep UI alive.
            AudioInputStream stream = AudioSystem.getAudioInputStream(new File(path));
            bgMusic = AudioSystem.getClip();
            bgMusic.open(stream);
            bgMusic.loop(Clip.LOOP_CONTINUOUSLY);
            bgMusic.start();
        } catch (Exception e) {
            // Consider logging the error in a production environment.
        }
    }

    private void loadResources() {
        try {
            // Load background and symbol images from Assets/. Scale to SYMBOL_SIZE and cache.
            // The bonus symbol (if present) is stored at key 10.
            backgroundImage = ImageIO.read(new File("Assets/ETM_Background.png"));
            for (int i = 1; i <= 9; i++) {
                File imgFile = new File("Assets/" + i + ".png");
                if (imgFile.exists()) {
                    Image img = ImageIO.read(imgFile).getScaledInstance(SYMBOL_SIZE, SYMBOL_SIZE, Image.SCALE_SMOOTH);
                    symbolIcons.put(i, new ImageIcon(img));
                }
            }
            File bonusFile = new File("Assets/bonus.png");
            if (bonusFile.exists()) {
                Image img = ImageIO.read(bonusFile).getScaledInstance(SYMBOL_SIZE, SYMBOL_SIZE, Image.SCALE_SMOOTH);
                symbolIcons.put(10, new ImageIcon(img));
            }
        } catch (Exception e) {
            // Loading failures are ignored here; UI handles missing icons gracefully.
        }
    }

    private void startAutospin(JButton button) {
        // Start automatic spins. autospinTimer callbacks run on the EDT and respect isSpinning.
        isAutospinning = true;
        button.setText("STOP");
        autospinTimer.start();
    }

    private void stopAutospin(JButton button) {
        // Stop automatic spins and update button label.
        isAutospinning = false;
        button.setText("AUTOSPIN");
        autospinTimer.stop();
    }

    private void runSpin(JLabel balanceLabel) {
        // Request a spin from native logic, then animate reel shuffles and stops using Swing Timers.
        // All UI updates occur on the EDT. The function sets isSpinning to prevent concurrent spins.
        double win = logic.spin();
        if (win < 0) return; // insufficient funds

        isSpinning = true;
        boolean bonusStart = logic.isBonusActive() && !resultLabel.getText().equals("BONUS SPIN!");
        
        if (logic.isBonusActive()) resultLabel.setText("BONUS SPIN!");
        else resultLabel.setText("Rolling...");
        
        int[][] board = logic.getLastBoard();

        // Animate each cell: create a shuffle timer and a stop timer per cell.
        for (int c = 0; c < 5; c++) {
            for (int r = 0; r < 3; r++) {
                final int row = r;
                final int col = c;
                int stopDelay = (c * 400) + (row * 100) + 800;

                Timer shuffleTimer = new Timer(70, null);
                shuffleTimer.addActionListener(e -> {
                    // Randomly display symbols during shuffle; show bonus occasionally.
                    int randomId = (Math.random() > 0.9) ? 10 : (int)(Math.random() * 9) + 1;
                    reelLabels[row][col].setIcon(symbolIcons.get(randomId));
                });
                shuffleTimer.start();

                Timer stopTimer = new Timer(stopDelay, e -> {
                    shuffleTimer.stop();
                    // Finalize the cell with the actual board value (may be 0 for empty).
                    updateCell(row, col, board[row][col]);
                    
                    // If this was the last cell to stop, branch based on bonus state.
                    if (row == 2 && col == 4) {
                        if (bonusStart) triggerBonusTransition(balanceLabel);
                        else if (logic.isBonusActive()) handleNextBonusSpin(balanceLabel);
                        else finishSpin(win, balanceLabel);
                    }
                });
                stopTimer.setRepeats(false);
                stopTimer.start();
            }
        }
    }

    private void updateCell(int r, int c, int id) {
        // Update a single cell's icon. id==0 clears the icon; otherwise uses cached icon.
        if (id == 0) reelLabels[r][c].setIcon(null);
        else reelLabels[r][c].setIcon(symbolIcons.get(id));
    }

    private void triggerBonusTransition(JLabel balanceLabel) {
        // Visual transition when entering bonus mode: flash empty and bonus icons before
        // proceeding into bonus spin sequence. Runs on the EDT via a Timer.
        Timer transition = new Timer(150, null);
        final int[] count = {0};
        transition.addActionListener(e -> {
            for (int r = 0; r < 3; r++) {
                for (int c = 0; c < 5; c++) {
                    if (count[0] % 2 == 0) reelLabels[r][c].setIcon(null);
                    else reelLabels[r][c].setIcon(symbolIcons.get(10));
                }
            }
            if (count[0]++ > 10) {
                transition.stop();
                handleNextBonusSpin(balanceLabel);
            }
        });
        transition.start();
    }

    private void handleNextBonusSpin(JLabel balanceLabel) {
        // Manage bonus spin sequence: if spins remain, schedule the next spin; otherwise
        // finalize the bonus and show total payout.
        if (logic.getBonusSpins() > 0) {
            resultLabel.setText("Bonus Spins: " + logic.getBonusSpins());
            Timer pause = new Timer(1200, e -> runSpin(balanceLabel));
            pause.setRepeats(false);
            pause.start();
        } else {
            double bonusWin = logic.finalizeBonus();
            resultLabel.setText("TOTAL WIN: " + String.format("%.2f", bonusWin));
            balanceLabel.setText("Balance: ₹" + String.format("%.2f", logic.getBalance()));
            isSpinning = false;
        }
    }

    private void finishSpin(double win, JLabel balanceLabel) {
        // Normal spin completion: update result text and balance display.
        isSpinning = false;
        if (win > 0) resultLabel.setText("Win: " + String.format("%.2f", win));
        else resultLabel.setText("No win");
        balanceLabel.setText("Balance: ₹" + String.format("%.2f", logic.getBalance()));
    }

    public static void main(String[] args) {
        // Launch the UI on the EDT. Ensures native assets are loaded before showing the window.
        SwingUtilities.invokeLater(() -> {
            window game = new window();
            JFrame frame = new JFrame("Edgar's Torture Machine");
            frame.setSize(1200, 800);
            frame.setResizable(false);
            frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
            if (game.logic.loadAssets()) {
                game.buildUI(frame);
                frame.setVisible(true);
            }
        });
    }
}