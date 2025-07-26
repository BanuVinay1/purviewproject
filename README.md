# 💼 Microsoft Purview + Compliance Automation Project

This project simulates a real-world enterprise data governance scenario using **Microsoft Purview**, **Compliance Manager**, and **GitHub Actions**. It automates critical data governance tasks like glossary management, resource deployment, and security compliance alignment — all mapped to **ISO 27005**.

## 🔧 Features

- ✅ **Automated Glossary Upload**  
  Upload business glossary terms into Microsoft Purview via REST API, powered by GitHub Actions + CSV input.

- ⚙️ **Resource Deployment Automation**  
  Deploy core Azure resources — Storage, Purview, Key Vault, App — using Azure CLI and secure secrets.

- 🔒 **Microsoft Compliance Manager Integration**  
  Aligns with ISO 27005 improvement actions such as risk assessments, security planning, vulnerability scanning, etc.

- 📁 **Retention Policies & DLP Setup**  
  Microsoft 365 retention and Data Loss Prevention policies configured for regulatory compliance.

- 🏷 **Sensitivity Labeling**  
  Sensitivity labels applied to M365 documents, with integration into Purview’s classification engine.

- 🔄 **End-to-End Data Lineage**  
  Tracked lineage from ADLS to ADF using Microsoft Purview's unified governance experience.

- 🔐 **CI/CD with GitHub Actions**  
  Includes token-based auth, managed identity patterns, and GitHub Secrets for secure automation.

## 🛠 Tools & Technologies

- Microsoft Purview (Unified Portal)
- Compliance Manager (ISO 27005)
- Azure CLI, REST API
- GitHub Actions (CI/CD)
- Azure Key Vault, ADLS Gen2, ADF
- Microsoft 365 Compliance Center (DLP, Retention)

Planned additions:
- [ ] Automated classification rule setup
- [ ] Custom scan rule sets via REST
- [ ] DLP alerts via Microsoft Graph API
- [ ] Full policy compliance reports
