#!/bin/bash

# Function to display ASCII art
display_ascii_art() {
cat << "EOF"
                                  ,----,    ,--,                                              
       ,--.          ,--.       ,/   .`| ,---.'|                                              
   ,--/  /|        ,--.'|     ,`   .'  : |   | :     ,--,     ,--,    .--.--.      .--.--.    
,---,': / '    ,--,:  : |   ;    ;     / :   : |     |'. \   / .`|   /  /    '.   /  /    '.  
:   : '/ /  ,`--.'`|  ' : .'___,/    ,'  |   ' :     ; \ `\ /' / ;  |  :  /`. /  |  :  /`. /  
|   '   ,   |   :  :  | | |    :     |   ;   ; '     `. \  /  / .'  ;  |  |--`   ;  |  |--`   
'   |  /    :   |   \ | : ;    |.';  ;   '   | |__    \  \/  / ./   |  :  ;_     |  :  ;_     
|   ;  ;    |   : '  '; | `----'  |  |   |   | :.'|    \  \.'  /     \  \    `.   \  \    `.  
:   '   \   '   ' ;.    ;     '   :  ;   '   :    ;     \  ;  ;       `----.   \   `----.   \ 
|   |    '  |   | | \   |     |   |  '   |   |  ./     / \  \  \      __ \  \  |   __ \  \  | 
'   : |.  \ '   : |  ; .'     '   :  |   ;   : ;      ;  /\  \  \    /  /`--'  /  /  /`--'  / 
|   | '_\.' |   | '`--'       ;   |.'    |   ,/     ./__;  \  ;  \  '--'.     /  '--'.     /  
'   : |     '   : |           '---'      '---'      |   : / \  \  ;   `--'---'     `--'---'   
;   |,'     ;   |.'                                 ;   |/   \  ' |                           
'---'       '---'                                   `---'     `--`                            
 
By  btxcode
X: https://x.com/btxcode
Supported GOME Team
EOF
}

# Function to install all tools
install_tools() {
    echo "[*] Installing required tools..."
    sudo -v || { echo "[ERROR] Sudo required. Please run with sudo privileges."; exit 1; }

    # Install Chrome
    sudo apt update && sudo apt install libu2f-udev golang-go -y
    sudo dpkg -i google-chrome-stable_114.0.5735.90-1_amd64.deb

    # Copy chromedriver and set execute permissions
    sudo chmod +x chromedriver
    sudo cp chromedriver /usr/local/bin/

    # Install gf tool (Gf Patterns)
    go install github.com/tomnomnom/gf@latest
    sudo mv ~/go/bin/gf /usr/local/bin/
    sudo chmod +x /usr/local/bin/gf

    # Remove existing .gf directory if it exists and clone the new one
    if [ -d "~/.gf" ]; then
        echo "[*] Removing existing .gf directory..."
        rm -rf ~/.gf
    fi

    echo "[*] Cloning .gf patterns..."
    git clone https://github.com/PushkraJ99/.gf
    mv .gf ~/

    # Install Arjun (HTTP parameter discovery tool) & hakrawler
    sudo apt update
    sudo apt install arjun hakrawler -y

    # Install waybackurls
    go install github.com/tomnomnom/waybackurls@latest
    sudo mv ~/go/bin/waybackurls /usr/local/bin/
    sudo chmod +x /usr/local/bin/waybackurls

    # Install gau
    go install github.com/lc/gau/v2/cmd/gau@latest
    sudo mv ~/go/bin/gau /usr/local/bin/
    sudo chmod +x /usr/local/bin/gau

    # Install waymore
    sudo pip3 install git+https://github.com/xnl-h4ck3r/waymore.git -v
    sudo pip3 install --upgrade waymore  # Ensure the latest version is installed

    # Install katana
    go install github.com/projectdiscovery/katana/cmd/katana@latest
    sudo mv ~/go/bin/katana /usr/local/bin/
    sudo chmod +x /usr/local/bin/katana

    # Install Subdominator
    sudo pip3 install git+https://github.com/RevoltSecurities/Subdominator

    # Install Subprober
    sudo pip3 install git+https://github.com/sanjai-AK47/Subprober.git

    # Install uro
    sudo pip3 install uro

    echo "[*] Tools installed successfully."
}

#!/bin/bash

# Function to prompt for domain input and proceed with domain enumeration and crawling
prompt_domain_and_proceed() {
    read -p "Please enter a domain name (example.com): " domain
    echo "[*] Domain name entered: $domain"

    # Create output directory for the domain if it doesn't exist
    mkdir -p output/$domain

    enumerate_domains_and_proceed
}

# Function to enumerate and filter domains
enumerate_domains_and_proceed() {
    echo "[*] Enumerating domains using Subdominator..."
    subdominator -d $domain -o output/$domain/domains.txt
    echo "[*] Domain enumeration complete."
    crawl_and_filter_urls
}

# Function to show loading progress
show_progress() {
    current=$1
    total=$2
    printf "\r[*] Processing link %d of %d..." "$current" "$total"
}

# Function to crawl and filter URLs
crawl_and_filter_urls() {
    echo "[*] Crawling URLs..."
    
    # Crawl and count total URLs, saving output to domain-specific folder
    waybackurls http://$domain | tee -a output/$domain/wayback.txt
    gau http://$domain | tee -a output/$domain/gau.txt
    waymore -i http://$domain -mode U -oU output/$domain/waymore.txt
    katana -u http://$domain -kf 3 | tee -a output/$domain/katana.txt

    # Merging all results into one file in the domain-specific folder
    cat output/$domain/*.txt > output/$domain/combined_urls.txt
    total=$(wc -l < output/$domain/combined_urls.txt)

    echo "[*] Merging and filtering URLs..."
    cat output/$domain/combined_urls.txt | uniq | sort -u > output/$domain/unique_urls.txt

    # Hakrawler & Subprober filtering
    echo "[*] Running hakrawler and Subprober for domain filtering..."
    cat output/$domain/domains.txt | httpx-toolkit | hakrawler | tee -a output/$domain/links.txt
    subprober -f output/$domain/domains.txt -sc -ar -o output/$domain/subprober_urls.txt -nc -mc 200 -c 30

    # Merging unique_urls.txt, links.txt, and subprober_urls.txt into all_urls.txt in the domain-specific folder
    cat "output/$domain/unique_urls.txt" "output/$domain/links.txt" "output/$domain/subprober_urls.txt" > output/$domain/all_urls.txt

    # Continue with filtering
    initial_filtering
}

# Function to perform initial filtering on URLs
initial_filtering() {
    echo "[*] Performing initial filtering on URLs..."
    
    # Perform initial filtering and save results in the domain-specific folder
    cat output/$domain/all_urls.txt | grep -E -v '\.css$|\.js$|\.jpg$|\.JPG$|\.PNG$|\.GIF$|\.avi$|\.dll$|\.pl$|\.webm$|\.c$|\.py$|\.bat$|\.tar$|\.swp$|\.tmp$|\.sh$|\.deb$|\.exe$|\.zip$|\.mpeg$|\.mpg$|\.flv$|\.wmv$|\.wma$|\.aac$|\.m4a$|\.ogg$|\.mp4$|\.mp3$|\.bat$|\.dat$|\.cfg$|\.cfm$|\.bin$|\.jpeg$|\.JPEG$|\.ps.gz$|\.gz$|\.gif$|\.tif$|\.tiff$|\.csv$|\.png$|\.ttf$|\.ppt$|\.pptx$|\.ppsx$|\.doc$|\.woff$|\.xlsx$|\.xls$|\.mpp$|\.mdb$|\.json$|\.woff2$|\.icon$|\.pdf$|\.docx$|\.svg$|\.txt$|\.jar$|\.0$|\.1$|\.2$|\.3$|\.4$|\.m4r$|\.kml$|\.pro$|\.yao$|\.gcn3$|\.PDF$|\.egy$|\.par$|\.lin$|\.yht$' > output/$domain/filtered_urls.txt
    grep -E '^https?://' output/$domain/filtered_urls.txt | sed 's/\[200\]//g' > output/$domain/filtered_cleaned_urls.txt

    # Running uro for further filtering
    echo "[*] Running uro for further filtering..."
    cat output/$domain/filtered_cleaned_urls.txt | uro -b css js jpg JPG PNG GIF avi dll pl webm c py bat tar swp tmp sh deb exe zip mpeg mpg flv wmv wma aac m4a ogg mp4 mp3 bat dat cfg cfm bin jpeg JPEG ps.gz gz gif tif tiff csv png ttf ppt pptx ppsx doc woff xlsx xls mpp mdb json woff2 icon pdf docx svg txt jar 0 1 2 3 4 m4r kml pro yao gcn3 PDF egy par lin yht | tee -a output/$domain/uro_filtered.txt

    # Unique filtering and cleaning up temporary files
    cat output/$domain/uro_filtered.txt | uniq | sort -u > output/$domain/final_filtered_urls.txt

    # Continue to final filtering
    final_filtering
}

# Function to filter URLs and perform final filtering
final_filtering() {
    echo "[*] Performing final filtering..."

    # Save final filtered results in the domain-specific folder
    grep '=' output/$domain/final_filtered_urls.txt > output/$domain/filtered_urls_with_params.txt   # Query URLs
    grep -v '=' output/$domain/final_filtered_urls.txt > output/$domain/filtered_urls_without_params.txt  # Path URLs
    cat output/$domain/final_filtered_urls.txt | grep -E "\.php|\.asp|\.aspx|\.cfm|\.jsp" | sort > output/$domain/output_php_asp.txt
    grep -v "http[^ ]*\.[^/]*\." output/$domain/final_filtered_urls.txt | grep "http" | sort > output/$domain/clean_urls.txt

    # Running arjun for parameter discovery
    arjun -i output/$domain/output_php_asp.txt -w parameters.txt -t 1 -oT output/$domain/arjun_params.txt

    # Merging all results into final_temp.txt in the domain-specific folder
    # cat output/$domain/filtered_urls_with_params.txt output/$domain/filtered_urls_without_params.txt output/$domain/output_php_asp.txt output/$domain/clean_urls.txt output/$domain/arjun_params.txt > output/$domain/final_urls.txt
    cat "output/$domain/filtered_urls_with_params.txt" "output/$domain/filtered_urls_without_params.txt" "output/$domain/output_php_asp.txt" "output/$domain/clean_urls.txt" "output/$domain/arjun_params.txt" > "output/$domain/final_urls.txt"


    # Clean up intermediate files and proceed to the next steps
    cleanup_intermediate_files
}

# Function to clean up intermediate files
cleanup_intermediate_files() {
    # Further processing and filtering based on gf patterns
    cat output/$domain/final_urls.txt | gf xss | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u > output/$domain/xss.txt
    cat output/$domain/final_urls.txt | gf sqli | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u > output/$domain/sqli.txt
    cat output/$domain/final_urls.txt | gf ssrf | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u > output/$domain/ssrf.txt
    cat output/$domain/final_urls.txt | gf ssti | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u > output/$domain/ssti.txt
    cat output/$domain/final_urls.txt | gf urlparams | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u > output/$domain/urlparams.txt
    cat output/$domain/final_urls.txt | gf redirect | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u > output/$domain/redirect.txt
    cat output/$domain/final_urls.txt | gf idor | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u > output/$domain/idor.txt
    cat output/$domain/final_urls.txt | gf lfi | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u > output/$domain/lfi.txt

    # Final merging and cleanup
    # cat output/$domain/xss.txt output/$domain/sqli.txt output/$domain/ssrf.txt output/$domain/ssti.txt output/$domain/urlparams.txt output/$domain/redirect.txt output/$domain/idor.txt output/$domain/lfi.txt | uniq > output/$domain/final.txt
    cat "output/$domain/xss.txt" "output/$domain/sqli.txt" "output/$domain/ssrf.txt" "output/$domain/ssti.txt" "output/$domain/urlparams.txt" "output/$domain/redirect.txt" "output/$domain/idor.txt" "output/$domain/lfi.txt" | uniq > "output/$domain/final.txt"
    # Menghilangkan port dari URL (port 80 dan 443, sebagai contoh umum)
    sed -e 's/:80//g' -e 's/:443//g' "output/$domain/final.txt" | sort -u > "output/$domain/final_clean.txt"
    # Clean up all intermediate files but keep final.txt and domains.txt
    find output/$domain/ -type f ! -name 'domains.txt' ! -name 'final_clean.txt' ! -name 'final.txt' -delete

    # Run XSS scanners
    run_xss_scanners
}

# Function to run XSS scanners (reflection and stored)
run_xss_scanners() {
    echo "[*] Running XSS scanners..."

    # Run reflection XSS scanner
    python3 reflection.py -l output/$domain/final_clean.txt --threads 1 --rua

    # Run stored XSS scanner
    python3 stored.py -l output/$domain/final_clean.txt --threads 1 --rua
}

# Quit function to clear terminal
quit_and_clear_terminal() {
    echo "[*] Stopping all background processes and cleaning up memory..."

    # Killing any background processes related to the tools
    pkill -f reflection.py
    pkill -f stored.py
    pkill -f waymore
    pkill -f gau
    pkill -f waybackurls
    pkill -f katana
    pkill -f subdominator
    pkill -f subprober
    pkill -f uro
    pkill -f chromedriver  # Kills all ChromeDriver processes
    pkill -f google-chrome  # Kills all Google Chrome processes

    # Flush system memory cache
    echo "[*] Flushing memory cache..."
    sudo sync && sudo sysctl -w vm.drop_caches=3

    echo "[*] Memory cleanup complete. Exiting..."
    sleep 1
    clear
    exit 0
}

# Main menu
while true; do
    display_ascii_art
    echo "Please select an option:"
    echo "1. Install all tools"
    echo "2. Enter a domain and start process XSS scanner"
    echo "3. Quit"

    read -p "Select an option: " option

    case $option in
        1) install_tools ;;
        2) prompt_domain_and_proceed ;;
        3) quit_and_clear_terminal ;;
        *) echo "Invalid option." ;;
    esac
done
