# CAIDA Spoofer Dockerized with Automated Email Reporting

This project wraps the [CAIDA Spoofer](https://www.caida.org/projects/spoofer/) prober in a Docker container. It automatically runs the spoofing tests, collects network metadata via ipwho.is, and emails the results using AWS SES (via msmtp).

## 🚀 Features
- **Ubuntu 22.04 Base**: Uses the official CAIDA PPA.
- **Auto-Reporting**: Parses CAIDA logs to find the session URL and summary results.
- **Metadata Enrichment**: Fetches Host IP, ASN, and ISP details via ipwho.is.
- **SMTP Integration**: Pre-configured for AWS SES with logic to break Gmail message threading.
- **Cleanup Script**: Includes a rebuild.sh script to handle Docker build cache cleanup.

## 🏃 Usage
1. Configure your credentials in a `.env` file (see docker-compose.yml for required variables).
2. Run `chmod +x entrypoint.sh rebuild.sh`.
3. Execute `./rebuild.sh`.
