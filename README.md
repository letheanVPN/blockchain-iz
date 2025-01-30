# Lethean (LTHN)

[![macOS](https://github.com/letheanVPN/blockchain/actions/workflows/macos.yml/badge.svg)](https://github.com/letheanVPN/blockchain/actions/workflows/macos.yml)
[![Windows](https://github.com/letheanVPN/blockchain/actions/workflows/windows.yml/badge.svg)](https://github.com/letheanVPN/blockchain/actions/workflows/windows.yml)
[![Linux](https://github.com/letheanVPN/blockchain/actions/workflows/linux.yml/badge.svg)](https://github.com/letheanVPN/blockchain/actions/workflows/linux.yml)

- Links: [LICENSE](LICENSE), [CONTRIBUTING](CONTRIBUTING.md), [Vulnerability Response Process](VULNERABILITY_RESPONSE_PROCESS.md)
- Compile: [BUILD.md](BUILD.md)


## Testnet

```
git clone --recursive https://github.com/letheanVPN/blockchain-iz.git testnet
cd testnet
make release-static-linux-x86_64-local-boost
$PWD/build/6.0.0/release/bin/letheand --testnet
```

### Make a wallet
```
$PWD/build/6.0.0/release/bin/lethean-wallet-cli --testnet --generate-new-wallet testnet
```

### open wallet
```
$PWD/build/6.0.0/release/bin/lethean-wallet-cli --testnet --wallet-file testnet
```
