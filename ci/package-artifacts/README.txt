================================================
Welcome to Lethean!
================================================

We are building a blockchain-backed decentralized VPN to make the internet a safer place.
This package contains the command line utilities needed to join the Lethean network.



------------------------------------------------
Getting Started - Synchronization
------------------------------------------------

Before you can participate in the network, your local copy of the blockchain data must be
synchronized to match the rest of the network.

Windows:
 - double-click the daemon: letheand.exe
 - blockchain data is stored in: C:\Users\[USERNAME]\AppData\Roaming\intensecoin

Linux or macOS:
 - open the terminal
 - change into the CLI archive directory: $ cd lethean-cli-archive-directory/
 - run the daemon: $ ./letheand
 - blockchain data is stored in: ~/.intensecoin


Synchronization can take several hours the first time. To check on progress, simply type
"status" and press enter. This is how you execute commands on the daemon. After it has
completed, your status message will look like this:

     Height: some-number/the-same-number (100.0%) on mainnet

It indicates that you have a copy of the same number of blocks that the network has
created. This is also called the "height" of the network.

Now you can run lethean-wallet-cli to set up your wallet. See optional commands below if experiencing issues with wallet sync.



------------------------------------------------
Basic Commands: letheand
------------------------------------------------

help
 - shows all possible commands

status
 - returns a summary of your synchronization status, network hashrate and connections


------------------------------------------------
Optional Commands: lethean-wallet-cli
------------------------------------------------

By default the local daemon is used to synchronize your wallet.
If you have issues synchronizing you may use a remote daemon for your wallet as shown below:

     lethean-wallet-cli --daemon-address sync.lethean.io:48782