import ssl
import datetime
import smtplib
from email.mime.text import MIMEText
from slack_sdk import WebClient

# List of domains and ports to check
domains = [
    {"name": "example.com", "port": 443},
    # Add more domains as needed
]

# SMTP email configuration
smtp_server = 'smtp.example.com'
smtp_port = 587
smtp_username = 'your_email@example.com'
smtp_password = 'your_password'
sender_email = 'your_email@example.com'
recipient_email = 'recipient@example.com'

# Slack configuration
slack_token = 'your_slack_token'
slack_channel = '#your_channel_name'

# Function to check SSL certificate expiration
def check_ssl_cert(domain, port):
    context = ssl.create_default_context()
    try:
        with context.wrap_socket(socket.socket(socket.AF_INET), server_hostname=domain) as sock:
            sock.connect((domain, port))
            cert = sock.getpeercert()
            exp_date_str = cert['notAfter']
            exp_date = datetime.datetime.strptime(exp_date_str, '%b %d %H:%M:%S %Y %Z')
            days_left = (exp_date - datetime.datetime.now()).days
            return days_left
    except Exception as e:
        return None

# Function to send email notification
def send_email(subject, message):
    msg = MIMEText(message)
    msg['Subject'] = subject
    msg['From'] = sender_email
    msg['To'] = recipient_email

    try:
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls()
            server.login(smtp_username, smtp_password)
            server.sendmail(sender_email, recipient_email, msg.as_string())
            print("Email notification sent successfully.")
    except Exception as e:
        print("Failed to send email notification:", str(e))

# Function to send Slack alert
def send_slack_alert(message):
    try:
        client = WebClient(token=slack_token)
        response = client.chat_postMessage(channel=slack_channel, text=message)
        if response["ok"]:
            print("Slack alert sent successfully.")
        else:
            print("Failed to send Slack alert.")
    except Exception as e:
        print("Failed to send Slack alert:", str(e))

# Main script
for domain_info in domains:
    domain = domain_info["name"]
    port = domain_info["port"]
    days_left = check_ssl_cert(domain, port)
    
    if days_left is not None and days_left < 15:
        subject = f"SSL Certificate Expiration Alert for {domain}"
        message = f"The SSL certificate for {domain} will expire in {days_left} days."
        send_email(subject, message)
        send_slack_alert(message)
