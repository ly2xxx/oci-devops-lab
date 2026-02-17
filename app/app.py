#!/usr/bin/env python3
"""
Demo Flask Application for OCI DevOps Lab
Simple web app to demonstrate Terraform + Ansible + Octopus deployment
"""

from flask import Flask, render_template_string, jsonify
import socket
import os
import datetime

app = Flask(__name__)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OCI DevOps Lab - Demo App</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 600px;
            width: 100%;
        }
        h1 {
            color: #667eea;
            margin-bottom: 10px;
            font-size: 2.5em;
        }
        .subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 1.1em;
        }
        .info-box {
            background: #f7f9fc;
            border-left: 4px solid #667eea;
            padding: 15px;
            margin: 15px 0;
            border-radius: 5px;
        }
        .info-box strong {
            color: #333;
            display: inline-block;
            width: 120px;
        }
        .status {
            display: inline-block;
            padding: 5px 15px;
            background: #10b981;
            color: white;
            border-radius: 20px;
            font-size: 0.9em;
            margin-left: 10px;
        }
        .tech-stack {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 20px;
        }
        .tech-badge {
            background: #667eea;
            color: white;
            padding: 8px 16px;
            border-radius: 15px;
            font-size: 0.9em;
        }
        .footer {
            margin-top: 30px;
            text-align: center;
            color: #999;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 OCI DevOps Lab</h1>
        <p class="subtitle">Terraform + Ansible + Octopus Deploy</p>
        
        <div class="info-box">
            <strong>Status:</strong>
            <span class="status">✓ Running</span>
        </div>
        
        <div class="info-box">
            <strong>Hostname:</strong> {{ hostname }}
        </div>
        
        <div class="info-box">
            <strong>Server IP:</strong> {{ server_ip }}
        </div>
        
        <div class="info-box">
            <strong>Deployed:</strong> {{ deploy_time }}
        </div>
        
        <div class="info-box">
            <strong>Version:</strong> 1.0.0
        </div>
        
        <h3 style="margin-top: 30px; color: #333;">Tech Stack</h3>
        <div class="tech-stack">
            <span class="tech-badge">🏗️ Terraform</span>
            <span class="tech-badge">⚙️ Ansible</span>
            <span class="tech-badge">🐙 Octopus</span>
            <span class="tech-badge">☁️ OCI</span>
            <span class="tech-badge">🐍 Flask</span>
            <span class="tech-badge">🔥 Nginx</span>
        </div>
        
        <div class="footer">
            <p>Deployed via automated CI/CD pipeline</p>
            <p>© 2026 Yang Li - OCI DevOps Lab</p>
        </div>
    </div>
</body>
</html>
"""

@app.route('/')
def home():
    """Main page"""
    hostname = socket.gethostname()
    server_ip = socket.gethostbyname(hostname)
    deploy_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    return render_template_string(
        HTML_TEMPLATE,
        hostname=hostname,
        server_ip=server_ip,
        deploy_time=deploy_time
    )

@app.route('/health')
def health():
    """Health check endpoint for monitoring"""
    return jsonify({
        'status': 'healthy',
        'hostname': socket.gethostname(),
        'timestamp': datetime.datetime.now().isoformat()
    })

@app.route('/api/info')
def info():
    """API endpoint with system info"""
    return jsonify({
        'hostname': socket.gethostname(),
        'ip': socket.gethostbyname(socket.gethostname()),
        'version': '1.0.0',
        'environment': os.getenv('ENVIRONMENT', 'dev'),
        'deployed_by': 'Octopus Deploy',
        'infrastructure': 'OCI Always Free Tier'
    })

if __name__ == '__main__':
    # Run on all interfaces, port 5000
    app.run(host='0.0.0.0', port=5000, debug=True)
