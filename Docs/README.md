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


## Update adding prison
The prison has been added to the Roblox world and there is an NPC placed outside the cell where the original spawnpoint will be set.
_TODO_: 
*   Make the NPC tell the player whats going on.
*   Right now it is impossible to walk through an arch in the prison which needs to be fixed so its possible to pass without any restrictions.
*   The cell door to the cell has to be programmed so it is opened upon joining the world.
