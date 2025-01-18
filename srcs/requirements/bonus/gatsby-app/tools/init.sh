#!/bin/sh
set -e

echo "=== Starting Static Server Initialization ==="

echo "1. Checking directory structure..."
# Check for the public directory that Gatsby creates after build
if [ ! -d "/app/public" ]; then
    echo "❌ ERROR: Public directory not found! Gatsby build may have failed."
    exit 1
fi
echo "✅ Public directory verified"

echo "2. Checking static file server..."
if ! command -v serve &> /dev/null; then
    echo "❌ ERROR: serve package is not installed!"
    exit 1
fi
echo "✅ Static file server is available"

echo "3. Verifying build output..."
# Check if the main HTML file exists
if [ ! -f "/app/public/index.html" ]; then
    echo "❌ ERROR: index.html not found in public directory!"
    exit 1
fi
echo "✅ Build output verified"

echo "=== Initialization complete. Starting static file server... ==="

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

# Execute the static file server
exec serve -s public -l 3000