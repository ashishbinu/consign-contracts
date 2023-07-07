# Consign

🔒 A Secure Blockchain-Based Solution for Certification Issuance 🔒

![Consign Logo](./docs/logo.png)

Consign is a cutting-edge project designed to tackle the challenges associated with certification forgery. In various industries, the need for reliable certifications and official documents is paramount to ensure professional competence and career progression. However, the prevalence of fake certificates and documents has become a significant concern, as they are becoming increasingly difficult to distinguish from authentic ones.

To address this issue, Consign proposes a secure and effective blockchain-based solution that guarantees the authenticity of certifications. By leveraging non-fungible tokens (NFTs), Consign provides a tamper-proof mechanism for verifying the legitimacy of certificates.

## Features

Consign offers the following key features to ensure a secure and reliable certificate issuance process:

🔒 **Soulbound NFTs**: Consign utilizes the Soulbound NFT standard (ERC5484) to represent certificates on the blockchain. This standard ensures the uniqueness and immutability of each certificate, preventing unauthorized replication or tampering. You can learn more about the ERC5484 standard [here](https://eips.ethereum.org/EIPS/eip-5484).

🔐 **Multisig Issuer Accounts**: To enhance security, Consign employs multisig issuer accounts. This means that certificate issuers require multiple authorized parties to validate and sign off on the issuance of a certificate. This ensures that no single entity has complete control over the issuance process, reducing the risk of fraud or misuse.

🔁 **Minimal Proxy Pattern**: Consign adopts the minimal proxy pattern (ERC1167) for creating multisig wallets for issuers. This pattern enables efficient and cost-effective deployment of issuer accounts by creating lightweight proxy contracts. The minimal proxy pattern reduces gas costs and simplifies the management of issuer accounts. To learn more about the ERC1167 standard, refer to the Ethereum Improvement Proposal [here](https://eips.ethereum.org/EIPS/eip-1167).

## Architecture

The Consign solution architecture is depicted below:

![Consign Contract Architecture](./docs/architecture.png)

<!-- https://excalidraw.com/#json=mGxSunhq11anYjXKYaJhi,X3KKDbP84dMZJOKvWd8c8g -->

For a detailed view of the architecture, you can visit the project repository [here](https://www.github.com/ashishbinu/consign-contracts).

## Installation

To install and set up the Consign project, follow these steps:

1. Clone the project repository:

    ```bash
    git clone https://www.github.com/ashishbinu/consign-contracts
    ```

2. Install the dependencies:

    ```bash
    forge install
    ```

3. Set up the Git hooks:
    ```bash
    make githook
    ```

## Contributing

We welcome contributions to make Consign an even more powerful solution against certification forgery. If you're interested in contributing to the project, please follow these guidelines:

1. Fork the project repository.

2. Create a new branch for your feature or bug fix:

    ```bash
    git checkout -b feature/your-feature-name
    ```

3. Make your changes and commit them with descriptive commit messages.

4. Push your changes to your forked repository.

5. Open a pull request against the main project repository.

Please provide as much detail as possible when opening a pull request, including the problem or feature you're addressing and the approach you've taken.

## Contact

If you have any questions, feedback, or suggestions regarding Consign, please feel free to reach out to us. You can contact the project maintainer at [ashishbinu90@gmail.com](mailto:ashishbinu90@gmail.com).

---

Thank you for your interest in Consign! Together, we can create a secure and trustworthy environment for certification issuance. 🚀
