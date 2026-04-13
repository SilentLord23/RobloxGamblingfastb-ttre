# Bet Buttons and Functions

## What was done:
*   Added initial values for the players bet and currency
    *   Initial Currency = 1000
    *   Initial Bet = 10
*   Added the logic for the buttons which
    *   Changes the bet
    *   Bet cant be changed during spin
    *   Checks your current currency to see if you are allowed to spin with the current selected bet
*   Changed location of the spin button logics to make sure everything is in the right place
* Important UI naming
    *   Label showing bet (on screen): CurrentBetLabel
    *   Frame containing the 10 buttons: BetButtons
    *   Button named after pricing: 5, 10, 15, 20, 25, 50, 75, 100, 250, 500