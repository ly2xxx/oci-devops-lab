# Exercise 4: Flask App Integration with Configu

**Time:** 45 minutes  
**Difficulty:** Advanced  
**Goal:** Integrate Configu with real Flask application

---

## 📚 Concepts Covered

- Loading configs in Python apps
- Database connection management
- Feature flags
- Multi-environment deployment
- Production best practices

---

## 🎯 Exercise Tasks

### Task 1: Create Flask App Schema (10 min)

**Design comprehensive config schema:**

```bash
cd ~/workspace/configu-exercises/exercise-4-flask-app

cat > flask-app.cfgu.json << 'EOF'
{
  "FLASK_ENV": {
    "type": "String",
    "required": true,
    "pattern": "^(development|production)$",
    "description": "Flask environment mode"
  },
  "SECRET_KEY": {
    "type": "String",
    "required": true,
    "description": "Flask secret key for sessions"
  },
  "DEBUG": {
    "type": "Boolean",
    "default": false,
    "description": "Enable Flask debug mode"
  },
  "HOST": {
    "type": "String",
    "default": "0.0.0.0",
    "description": "Flask server host"
  },
  "PORT": {
    "type": "Number",
    "default": 5000,
    "description": "Flask server port"
  },
  "DATABASE_URL": {
    "type": "String",
    "required": true,
    "description": "PostgreSQL connection string"
  },
  "REDIS_URL": {
    "type": "String",
    "default": "redis://localhost:6379/0",
    "description": "Redis cache URL"
  },
  "LOG_LEVEL": {
    "type": "String",
    "default": "INFO",
    "pattern": "^(DEBUG|INFO|WARNING|ERROR|CRITICAL)$"
  },
  "MAX_CONTENT_LENGTH": {
    "type": "Number",
    "default": 16777216,
    "description": "Max upload size in bytes (16MB)"
  },
  "FEATURE_REGISTRATION": {
    "type": "Boolean",
    "default": true,
    "description": "Enable user registration"
  },
  "FEATURE_API_V2": {
    "type": "Boolean",
    "default": false,
    "description": "Enable API v2 endpoints"
  },
  "RATE_LIMIT_ENABLED": {
    "type": "Boolean",
    "default": true,
    "description": "Enable rate limiting"
  },
  "RATE_LIMIT_PER_MINUTE": {
    "type": "Number",
    "default": 60,
    "description": "API calls per minute per IP"
  }
}
EOF

# Validate schema
cat flask-app.cfgu.json | jq .
```

**✅ Checkpoint:** Schema covers all Flask app needs.

---

### Task 2: Configure Environments (10 min)

**Set up dev/staging/prod configs:**

```bash
mkdir -p stores secrets

# .configu setup
cat > .configu << 'EOF'
{
  "stores": [
    {
      "type": "json-file",
      "configuration": {
        "path": "./stores/flask-config.json"
      }
    }
  ]
}
EOF

# Development
configu upsert \
  --store ./stores/flask-config.json \
  --set "flask/development" \
  --schema ./flask-app.cfgu.json \
  -c "FLASK_ENV=development" \
  -c "SECRET_KEY=dev-secret-key-not-secure" \
  -c "DEBUG=true" \
  -c "HOST=127.0.0.1" \
  -c "PORT=5000" \
  -c "DATABASE_URL=postgresql://dev:dev@localhost/flask_dev" \
  -c "LOG_LEVEL=DEBUG" \
  -c "FEATURE_REGISTRATION=true" \
  -c "FEATURE_API_V2=true" \
  -c "RATE_LIMIT_ENABLED=false"

# Production
configu upsert \
  --store ./stores/flask-config.json \
  --set "flask/production" \
  --schema ./flask-app.cfgu.json \
  -c "FLASK_ENV=production" \
  -c "SECRET_KEY=CHANGE_THIS_IN_PRODUCTION" \
  -c "DEBUG=false" \
  -c "HOST=0.0.0.0" \
  -c "PORT=8000" \
  -c "DATABASE_URL=postgresql://produser:CHANGEME@prod-db.internal/flask_prod" \
  -c "REDIS_URL=redis://prod-redis.internal:6379/0" \
  -c "LOG_LEVEL=WARNING" \
  -c "FEATURE_REGISTRATION=true" \
  -c "FEATURE_API_V2=false" \
  -c "RATE_LIMIT_ENABLED=true" \
  -c "RATE_LIMIT_PER_MINUTE=100"

# Verify configs
echo "=== Development Config ==="
configu export \
  --store ./stores/flask-config.json \
  --set "flask/development" \
  --schema ./flask-app.cfgu.json \
  --format "Dotenv"
```

**✅ Checkpoint:** Configs ready for both environments.

---

### Task 3: Create Flask App with Configu (15 min)

**Build Python app that loads Configu configs:**

```bash
cat > app.py << 'EOF'
#!/usr/bin/env python3
"""
Flask App with Configu Configuration Management
"""

import os
import sys
import subprocess
import json
from flask import Flask, jsonify, request
from functools import wraps

# Load configuration from Configu
def load_config_from_configu(environment='development'):
    """Load configuration using Configu CLI"""
    try:
        # Export configs from Configu
        result = subprocess.run([
            'configu', 'export',
            '--store', './stores/flask-config.json',
            '--set', f'flask/{environment}',
            '--schema', './flask-app.cfgu.json',
            '--format', 'JSON'
        ], capture_output=True, text=True, check=True)
        
        config = json.loads(result.stdout)
        return config
    except subprocess.CalledProcessError as e:
        print(f"Error loading config: {e.stderr}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing config JSON: {e}")
        sys.exit(1)

# Determine environment from ENV var or default to development
ENVIRONMENT = os.getenv('FLASK_ENVIRONMENT', 'development')
print(f"🔧 Loading configuration for environment: {ENVIRONMENT}")

# Load config
config = load_config_from_configu(ENVIRONMENT)

# Create Flask app
app = Flask(__name__)

# Apply configuration
app.config.update(config)
app.secret_key = config['SECRET_KEY']

# Feature flag decorator
def feature_flag(flag_name):
    """Decorator to enable/disable endpoints based on feature flags"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not app.config.get(flag_name, False):
                return jsonify({
                    'error': 'Feature not enabled',
                    'feature': flag_name
                }), 403
            return f(*args, **kwargs)
        return decorated_function
    return decorator

# Rate limiting decorator (simplified)
def rate_limit(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if app.config.get('RATE_LIMIT_ENABLED', False):
            # In production: implement real rate limiting with Redis
            # For now, just log
            app.logger.debug(f"Rate limit check: {request.remote_addr}")
        return f(*args, **kwargs)
    return decorated_function

# Routes
@app.route('/')
def index():
    return jsonify({
        'app': 'Flask with Configu',
        'environment': config['FLASK_ENV'],
        'features': {
            'registration': config['FEATURE_REGISTRATION'],
            'api_v2': config['FEATURE_API_V2']
        }
    })

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'environment': config['FLASK_ENV'],
        'debug': config['DEBUG']
    })

@app.route('/config')
def show_config():
    """Show non-sensitive configuration (debug only)"""
    if not config['DEBUG']:
        return jsonify({'error': 'Debug mode required'}), 403
    
    # Filter out sensitive keys
    safe_config = {k: v for k, v in config.items() 
                   if not any(s in k.lower() for s in ['secret', 'password', 'key'])}
    return jsonify(safe_config)

@app.route('/api/v1/users')
@rate_limit
def api_v1_users():
    """API v1 endpoint"""
    return jsonify({
        'version': 'v1',
        'users': ['alice', 'bob', 'charlie']
    })

@app.route('/api/v2/users')
@rate_limit
@feature_flag('FEATURE_API_V2')
def api_v2_users():
    """API v2 endpoint (feature-flagged)"""
    return jsonify({
        'version': 'v2',
        'users': [
            {'id': 1, 'name': 'alice', 'active': True},
            {'id': 2, 'name': 'bob', 'active': True},
            {'id': 3, 'name': 'charlie', 'active': False}
        ]
    })

@app.route('/register', methods=['POST'])
@feature_flag('FEATURE_REGISTRATION')
def register():
    """User registration (feature-flagged)"""
    return jsonify({
        'message': 'Registration successful',
        'username': request.json.get('username')
    })

if __name__ == '__main__':
    print(f"🚀 Starting Flask app")
    print(f"   Environment: {config['FLASK_ENV']}")
    print(f"   Debug: {config['DEBUG']}")
    print(f"   Host: {config['HOST']}:{config['PORT']}")
    print(f"   Features: Registration={config['FEATURE_REGISTRATION']}, API_V2={config['FEATURE_API_V2']}")
    
    app.run(
        host=config['HOST'],
        port=int(config['PORT']),
        debug=config['DEBUG']
    )
EOF

chmod +x app.py
```

**✅ Checkpoint:** Flask app loads config from Configu.

---

### Task 4: Test Multi-Environment Deployment (10 min)

**Run app in different environments:**

```bash
# Create test scripts
cat > run-dev.sh << 'EOF'
#!/bin/bash
echo "🔵 Running in DEVELOPMENT mode"
export FLASK_ENVIRONMENT=development
python3 app.py
EOF

cat > run-prod.sh << 'EOF'
#!/bin/bash
echo "🔴 Running in PRODUCTION mode"
export FLASK_ENVIRONMENT=production
python3 app.py
EOF

chmod +x run-dev.sh run-prod.sh

# Test development
./run-dev.sh &
DEV_PID=$!
sleep 3

# Test endpoints
echo "=== Testing Development Mode ==="
curl http://127.0.0.1:5000/
curl http://127.0.0.1:5000/health
curl http://127.0.0.1:5000/config  # Should work (debug=true)
curl http://127.0.0.1:5000/api/v2/users  # Should work (feature enabled)

# Stop dev server
kill $DEV_PID

# Test production (change port to 8000 in config first)
echo -e "\n=== Testing Production Mode ==="
# Run: ./run-prod.sh
# Test that /config returns 403 (debug=false)
# Test that /api/v2/users returns 403 (feature disabled)
```

**✅ Checkpoint:** App behaves differently per environment.

---

## 🎓 What You Learned

- ✅ Created production-ready Flask app schema
- ✅ Loaded Configu configs in Python
- ✅ Implemented feature flags
- ✅ Environment-specific behavior
- ✅ Config-driven deployment

---

## 🧪 Challenge Tasks

1. **Add Database Connection**
   ```python
   from sqlalchemy import create_engine
   engine = create_engine(config['DATABASE_URL'])
   ```

2. **Implement Real Rate Limiting**
   ```python
   from flask_limiter import Limiter
   limiter = Limiter(app, key_func=lambda: request.remote_addr)
   ```

3. **Add Monitoring**
   ```python
   from prometheus_flask_exporter import PrometheusMetrics
   metrics = PrometheusMetrics(app)
   ```

4. **Create Deployment Pipeline**
   ```bash
   deploy.sh:
   - Load config for $ENV
   - Run database migrations
   - Start app
   - Health check
   - Rollback if failed
   ```

---

## 📖 Production Deployment Pattern

```bash
# deploy.sh
#!/bin/bash
set -e

ENV=${1:-production}
echo "🚀 Deploying to $ENV"

# 1. Load configuration
configu export \
  --store ./stores/flask-config.json \
  --set "flask/$ENV" \
  --schema ./flask-app.cfgu.json \
  --format "Dotenv" > .env.$ENV

# 2. Load secrets from vault
source secrets/.env.$ENV

# 3. Validate configuration
python3 -c "from app import config; assert config['FLASK_ENV'] == '$ENV'"

# 4. Run migrations
flask db upgrade

# 5. Start app (systemd/supervisor/docker)
systemctl restart flask-app

# 6. Health check
sleep 5
curl -f http://localhost:8000/health || (systemctl stop flask-app && exit 1)

echo "✅ Deployment successful!"
```

---

## 🚀 Next Steps

✅ **Exercise 4 Complete! All Configu Exercises Done!** 🎉

**You now know:**
- Config schemas and validation
- Multi-environment management
- Secrets handling
- Real application integration
- Production deployment patterns

**Apply this to:**
- Your existing projects
- New microservices
- DevOps pipelines
- Team configurations

**Further Learning:**
- HashiCorp Vault integration
- Kubernetes ConfigMaps
- GitOps with configs
- Config as Code patterns

---

**Congratulations on completing the Configu exercises!** 🎓
