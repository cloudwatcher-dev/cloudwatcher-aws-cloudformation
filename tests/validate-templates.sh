#!/bin/bash

# CloudFormation Template Validation Script
# Tests RootStack and all SubStacks for syntax and logical errors

set -e

TEMPLATES_DIR="src/templates/organisation/0.1"
ALARMS_DIR="$TEMPLATES_DIR/alarms/CW"

echo "🔍 Validating CloudFormation Templates..."
echo "========================================"

# Function to test a template
test_template() {
    local template=$1
    local name=$(basename "$template")
    
    echo ""
    echo "Testing: $name"
    echo "----------------------------------------"
    
    # Check if cfn-lint is installed
    if command -v cfn-lint &> /dev/null; then
        cfn-lint "$template" && echo "✅ $name: PASSED" || echo "❌ $name: FAILED"
    else
        echo "⚠️  cfn-lint not installed. Install with: pip install cfn-lint"
        # Fallback to basic YAML validation
        if command -v yamllint &> /dev/null; then
            yamllint "$template" && echo "✅ $name: YAML Valid" || echo "❌ $name: YAML Invalid"
        else
            echo "⚠️  yamllint not installed. Install with: pip install yamllint"
            echo "ℹ️  Skipping validation for $name"
        fi
    fi
}

# Test RootStack
echo ""
echo "📋 Testing Root Stack"
test_template "$TEMPLATES_DIR/RootStack.yaml"

# Test SubStacks
echo ""
echo "📋 Testing Sub Stacks"
test_template "$TEMPLATES_DIR/ForwardingLambda.yaml"
test_template "$TEMPLATES_DIR/AccountDetailsLambda.yaml"
test_template "$TEMPLATES_DIR/CloudWatchAlarms.yaml"

# Test Alarm Templates
echo ""
echo "📋 Testing Alarm Templates"
if [ -d "$ALARMS_DIR" ]; then
    for alarm in "$ALARMS_DIR"/*.yaml; do
        if [ -f "$alarm" ]; then
            test_template "$alarm"
        fi
    done
else
    echo "⚠️  Alarms directory not found: $ALARMS_DIR"
fi

echo ""
echo "========================================"
echo "✅ Validation Complete!"
echo ""
echo "💡 To install testing tools:"
echo "   pip install cfn-lint yamllint"
