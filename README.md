# Exorcist

Exorcist (both types) forks and essentially removes the `Soulbound` properties (i.e an address's balance never decreases, either fixed or increases) of a Soulbound token, making it transferable and in an optimal way.

## Exorcist

Exorcist works for all Soulbound token types as long as the balance of any address does not decrease but is best optimized for Soulbound tokens with possibility of user balances increasing. This is because it has checks and syncs balances before each transfer

## ExorcistStaticBalance

ExorcistStaticBalance is similar to Exorcist but is optmized for Soulbound tokens where the balance of a user is expected to remain constant forever. This is because it only syncs balances once for each user (the first time they send or receive tokens) and never syncs again.
