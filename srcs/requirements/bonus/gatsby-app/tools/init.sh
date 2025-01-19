#!/bin/sh
set -e

echo "=== Starting Gatsby Server Initialization ==="

echo "1. Verifying environment..."
if ! command -v node > /dev/null; then
    echo "❌ ERROR: Node.js is not installed!"
    exit 1
fi
if ! command -v gatsby > /dev/null; then
    echo "❌ ERROR: Gatsby CLI is not installed!"
    exit 1
fi
echo "✅ Environment verified"

echo "2. Checking project structure..."
if [ ! -f "/app/package.json" ]; then
    echo "❌ ERROR: package.json not found!"
    exit 1
fi
if [ ! -f "/app/gatsby-config.js" ]; then
    echo "❌ ERROR: gatsby-config.js not found!"
    exit 1
fi
echo "✅ Project structure verified"

echo "3. Installing dependencies..."
# Check if node_modules exists and install if needed
if [ ! -d "/app/node_modules" ]; then
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ ERROR: Failed to install dependencies!"
        exit 1
    fi
fi
echo "✅ Dependencies installed"

echo "4. Building Gatsby site..."
gatsby clean
gatsby build
if [ ! -d "/app/public" ]; then
    echo "❌ ERROR: Build failed - public directory not found!"
    exit 1
fi
echo "✅ Build completed successfully"

echo "5. Verifying static server..."
if ! command -v serve > /dev/null; then
    echo "Installing serve package..."
    npm install -g serve
    if [ $? -ne 0 ]; then
        echo "❌ ERROR: Failed to install serve package!"
        exit 1
    fi
fi
echo "✅ Static server verified"

echo "=== Initialization complete. Starting server... ==="


cat << "EOF"

      ....        .                    s       .x+=:.         ..                                                                  
   .x88" `^x~  xH(`                   :8      z`    ^%  . uW8"        ..                                                          
  X888   x8 ` 8888h                  .88         .   <k `t888        @L                                .d``          .d``         
 88888  888.  %8888         u       :888ooo    .@8Ned8"  8888   .   9888i   .dL                 u      @8Ne.   .u    @8Ne.   .u   
<8888X X8888   X8?       us888u.  -*8888888  .@^%8888"   9888.z88N  `Y888k:*888.             us888u.   %8888:u@88N   %8888:u@88N  
X8888> 488888>"8888x  .@88 "8888"   8888    x88:  `)8b.  9888  888E   888E  888I          .@88 "8888"   `888I  888.   `888I  888. 
X8888>  888888 '8888L 9888  9888    8888    8888N=*8888  9888  888E   888E  888I          9888  9888     888I  888I    888I  888I 
?8888X   ?8888>'8888X 9888  9888    8888     %8"    R88  9888  888E   888E  888I          9888  9888     888I  888I    888I  888I 
 8888X h  8888 '8888~ 9888  9888   .8888Lu=   @8Wou 9%   9888  888E   888E  888I 88888888 9888  9888   uW888L  888'  uW888L  888' 
  ?888  -:8*"  <888"  9888  9888   ^%888*   .888888P`   .8888  888"  x888N><888' 88888888 9888  9888  '*88888Nu88P  '*88888Nu88P  
   `*88.      :88%    "888*""888"    'Y"    `   ^"F      `%888*%"     "88"  888           "888*""888" ~ '88888F`    ~ '88888F`    
      ^"~====""`       ^Y"   ^Y'                            "`              88F            ^Y"   ^Y'     888 ^         888 ^      
                                                                           98"                           *8E           *8E        
                                                                         ./"                             '8>           '8>        
                                                                        ~`                                "             "         
EOF

# Start the static file server
# Note: Using exec to replace shell with server process
exec serve -s public -l 3000 --cors