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

    # Install Chrome, Arjun (HTTP parameter discovery tool) & hakrawler
    sudo apt update && sudo apt install libu2f-udev golang-go httpx-toolkit arjun hakrawler -y
    sudo dpkg -i google-chrome-stable_114.0.5735.90-1_amd64.deb

    # Copy chromedriver and set execute permissions
    sudo chmod +x chromedriver
    sudo cp chromedriver /usr/local/bin/

    # Pengecekan apakah Arjun terinstall dengan benar
    if ! command -v arjun &> /dev/null; then
        echo "[ERROR] arjun is not installed."
    else
        echo "[*] arjun successfully installed."
    fi

    # Pengecekan apakah Chrome dan chromedriver terinstall dengan benar
    if ! command -v google-chrome &> /dev/null; then
        echo "[ERROR] google-chrome is not installed."
    else
        echo "[*] google-chrome successfully installed."
    fi

    if ! command -v chromedriver &> /dev/null; then
        echo "[ERROR] chromedriver is not installed."
    else
        echo "[*] chromedriver successfully installed."
    fi

    # Pengecekan apakah hakrawler terinstall dengan benar
    if ! command -v hakrawler &> /dev/null; then
        echo "[ERROR] hakrawler is not installed."
    else
        echo "[*] hakrawler successfully installed."
    fi
    
    # Install gf tool (Gf Patterns)
    go install github.com/tomnomnom/gf@latest
    sudo mv ~/go/bin/gf /usr/local/bin/
    sudo chmod +x /usr/local/bin/gf

    # Pengecekan apakah gf terinstall dengan benar
    if ! command -v gf &> /dev/null; then
        echo "[ERROR] gf is not installed."
    else
        echo "[*] gf successfully installed."
    fi

    # Remove existing .gf directory if it exists and clone the new one
    if [ -d "~/.gf" ]; then
        echo "[*] Removing existing .gf directory..."
        rm -rf ~/.gf
    fi

    echo "[*] Cloning .gf patterns..."
    git clone https://github.com/PushkraJ99/.gf
    mv .gf ~/

    # Install waybackurls
    go install github.com/tomnomnom/waybackurls@latest
    sudo mv ~/go/bin/waybackurls /usr/local/bin/
    sudo chmod +x /usr/local/bin/waybackurls

    # Pengecekan apakah waybackurls terinstall dengan benar
    if ! command -v waybackurls &> /dev/null; then
        echo "[ERROR] waybackurls is not installed."
    else
        echo "[*] waybackurls successfully installed."
    fi

   # Install gau
    go install github.com/lc/gau/v2/cmd/gau@latest
    sudo mv ~/go/bin/gau /usr/local/bin/
    sudo chmod +x /usr/local/bin/gau

    # Pengecekan apakah gau terinstall dengan benar
    if ! command -v gau &> /dev/null; then
        echo "[ERROR] gau is not installed."
    else
        echo "[*] gau successfully installed."
    fi


    # Install waymore
    sudo pip3 install git+https://github.com/xnl-h4ck3r/waymore.git -v
    sudo pip3 install --upgrade waymore  # Ensure the latest version is installed

    # Pengecekan apakah waymore terinstall dengan benar
    if ! pip3 show waymore &> /dev/null; then
        echo "[ERROR] waymore is not installed."
    else
        echo "[*] waymore successfully installed."
    fi
    
   # Install katana
    go install github.com/projectdiscovery/katana/cmd/katana@latest
    sudo mv ~/go/bin/katana /usr/local/bin/
    sudo chmod +x /usr/local/bin/katana

    # Pengecekan apakah katana terinstall dengan benar
    if ! command -v katana &> /dev/null; then
        echo "[ERROR] katana is not installed."
    else
        echo "[*] katana successfully installed."
    fi

    # Install Subdominator
    sudo pip3 install git+https://github.com/RevoltSecurities/Subdominator

    # Pengecekan apakah Subdominator terinstall dengan benar
    if ! pip3 show Subdominator &> /dev/null; then
        echo "[ERROR] Subdominator is not installed."
    else
        echo "[*] Subdominator successfully installed."
    fi

    # Install Subprober
    sudo pip3 install git+https://github.com/sanjai-AK47/Subprober.git

    # Pengecekan apakah Subprober terinstall dengan benar
    if ! pip3 show Subprober &> /dev/null; then
        echo "[ERROR] Subprober is not installed."
    else
        echo "[*] Subprober successfully installed."
    fi

    # Install uro
    sudo pip3 install uro

    # Pengecekan apakah uro terinstall dengan benar
    if ! pip3 show uro &> /dev/null; then
        echo "[ERROR] uro is not installed."
    else
        echo "[*] uro successfully installed."
    fi

    # Installing Depedency python
    sudo pip3 install -r requirements.txt

    echo "[*] Tools installed successfully."
}


# Function to check if tools are installed and have the right permissions
check_tools() {
    echo "[*] Checking installed tools and permissions..."

    # Array of tools to check with their respective paths
    tools=(
        "/usr/local/bin/waybackurls"
        "/usr/local/bin/gau"
        "/usr/local/bin/katana"
        "/usr/local/bin/gf"
        "/usr/local/bin/chromedriver"
        # Add any other tools here...
    )

    for tool in "${tools[@]}"; do
        if [ -f "$tool" ]; then
            # Check if tool has executable permissions
            if [ -x "$tool" ]; then
                echo "[*] $tool is installed and executable."
            else
                echo "[WARNING] $tool is installed but not executable. Fixing permissions..."
                sudo chmod +x "$tool"
            fi
        else
            echo "[ERROR] $tool is not installed."
        fi
    done

    # Additionally, check Python tools using `pip list`
    python_tools=("waymore" "uro" "subdominator" "subprober")
    for ptool in "${python_tools[@]}"; do
        if pip3 show "$ptool" > /dev/null 2>&1; then
            echo "[*] Python tool $ptool is installed."
        else
            echo "[ERROR] Python tool $ptool is not installed."
        fi
    done
}


#===============================================================================================================================================#

# Function to display a spinner for loading animation
show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "\b\b\b\b\b\b"  # Clear spinner when done
    echo " [DONE]"          # Print done message
}

# Function to prompt for domain input and proceed with domain enumeration and crawling
prompt_domain_and_proceed() {
    read -p "Please enter a domain name (example.com): " domain
    echo "[*] Domain name entered: $domain"

    # Save the current directory (starting point)
    original_dir=$(pwd)

    # Create output directory for the domain if it doesn't exist
    mkdir -p "output/$domain"

    # Change to the domain-specific directory
    cd "output/$domain"

    enumerate_domains_and_proceed
}

# Function to enumerate and filter domains
enumerate_domains_and_proceed() {
    echo "[*] Enumerating domains using Subdominator..."
    if [ -f "domains.txt" ]; then
        echo "[*] domains.txt already exists, skipping Subdominator."
    else
        subdominator -d $domain -o domains.txt &
        show_spinner $!
        echo "[*] Domain enumeration complete."
    fi

    crawl_and_filter_urls &
    show_spinner $!
}

# Function to crawl and filter URLs
crawl_and_filter_urls() {
    echo "[*] Crawling URLs..."

    # Check if waybackurls output exists
    if [ -f "wayback.txt" ]; then
        echo "[*] waybackurls output already exists, skipping."
    else
        waybackurls http://$domain | tee -a wayback.txt &
        show_spinner $!
    fi

    # Check if gau output exists
    if [ -f "gau.txt" ]; then
        echo "[*] GAU output already exists, skipping."
    else
        gau http://$domain | tee -a gau.txt &
        show_spinner $!
    fi

    # Check if waymore output exists
    if [ -f "waymore.txt" ]; then
        echo "[*] waymore output already exists, skipping."
    else
        waymore -i http://$domain -mode U -oU waymore.txt &
        show_spinner $!
    fi

    # Check if katana output exists
    if [ -f "katana.txt" ]; then
        echo "[*] katana output already exists, skipping."
    else
        katana -u http://$domain -kf 3 | tee -a katana.txt &
        show_spinner $!
    fi

    # Merging all results into one file in the domain-specific folder
    if [ -f "combined_urls.txt" ]; then
        echo "[*] combined_urls.txt already exists, skipping."
    else
        cat wayback.txt gau.txt waymore.txt katana.txt > combined_urls.txt &
        show_spinner $!
    fi

    # Running further filtering and unique check
    if [ -f "unique_urls.txt" ]; then
        echo "[*] unique_urls.txt already exists, skipping."
    else
        echo "[*] Merging and filtering URLs..."
        cat combined_urls.txt | uniq | sort -u > unique_urls.txt &
        show_spinner $!
    fi

    # Hakrawler & Subprober filtering
    if [ -f "links.txt" ] && [ -f "subprober_urls.txt" ]; then
        echo "[*] Hakrawler and Subprober output already exists, skipping."
    else
        echo "[*] Running hakrawler and Subprober for domain filtering..."
        cat domains.txt | httpx-toolkit | hakrawler | tee -a links.txt &
        show_spinner $!
        subprober -f domains.txt -sc -ar -o subprober_urls.txt -nc -mc 200 -c 30 &
        show_spinner $!
    fi

    # Check if all_urls.txt exists
    if [ -f "all_urls.txt" ]; then
        echo "[*] all_urls.txt already exists, skipping."
    else
        cat unique_urls.txt links.txt subprober_urls.txt > all_urls.txt &
        show_spinner $!
    fi

    # Continue with filtering
    initial_filtering &
    show_spinner $!
}

# Function to perform initial filtering on URLs
initial_filtering() {
    echo "[*] Performing initial filtering on URLs..."

    # Perform initial filtering and save results in the domain-specific folder
    if [ -f "filtered_urls.txt" ]; then
        echo "[*] filtered_urls.txt already exists, skipping."
    else
        cat all_urls.txt | grep -E -v '\.css$|\.js$|\.jpg$|\.JPG$|\.PNG$|\.GIF$|\.avi$|\.dll$|\.pl$|\.webm$|\.c$|\.py$|\.bat$|\.tar$|\.swp$|\.tmp$|\.sh$|\.deb$|\.exe$|\.zip$|\.mpeg$|\.mpg$|\.flv$|\.wmv$|\.wma$|\.aac$|\.m4a$|\.ogg$|\.mp4$|\.mp3$|\.bat$|\.dat$|\.cfg$|\.cfm$|\.bin$|\.jpeg$|\.JPEG$|\.ps.gz$|\.gz$|\.gif$|\.tif$|\.tiff$|\.csv$|\.png$|\.ttf$|\.ppt$|\.pptx$|\.ppsx$|\.doc$|\.woff$|\.xlsx$|\.xls$|\.mpp$|\.mdb$|\.json$|\.woff2$|\.icon$|\.pdf$|\.docx$|\.svg$|\.txt$|\.jar$|\.0$|\.1$|\.2$|\.3$|\.4$|\.m4r$|\.kml$|\.pro$|\.yao$|\.gcn3$|\.PDF$|\.egy$|\.par$|\.lin$|\.yht$' > filtered_urls.txt &
        show_spinner $!
        grep -E '^https?://' filtered_urls.txt | sed 's/\[200\]//g' > filtered_cleaned_urls.txt &
        show_spinner $!
    fi

    # Running uro for further filtering
    if [ -f "uro_filtered.txt" ]; then
        echo "[*] uro_filtered.txt already exists, skipping."
    else
        echo "[*] Running uro for further filtering..."
        cat filtered_cleaned_urls.txt | uro -b css js jpg JPG PNG GIF avi dll pl webm c py bat tar swp tmp sh deb exe zip mpeg mpg flv wmv wma aac m4a ogg mp4 mp3 bat dat cfg cfm bin jpeg JPEG ps.gz gz gif tif tiff csv png ttf ppt pptx ppsx doc woff xlsx xls mpp mdb json woff2 icon pdf docx svg txt jar 0 1 2 3 4 m4r kml pro yao gcn3 PDF egy par lin yht | tee -a uro_filtered.txt &
        show_spinner $!
    fi

    # Check if final_filtered_urls.txt exists
    if [ -f "final_filtered_urls.txt" ]; then
        echo "[*] final_filtered_urls.txt already exists, skipping."
    else
        cat uro_filtered.txt | uniq | sort -u > final_filtered_urls.txt &
        show_spinner $!
    fi
    
    find -type f ! -name 'final_filtered_urls.txt' -delete &
    show_spinner $!
    # Continue to final filtering
    final_filtering &
    show_spinner $!
}

# Function to filter URLs and perform final filtering
final_filtering() {
    echo "[*] Performing final filtering..."

    # Save final filtered results
    if [ -f "final_urls.txt" ]; then
        echo "[*] final_urls.txt already exists, skipping."
    else
        grep '=' final_filtered_urls.txt > filtered_urls_with_params.txt   # Query URLs
        grep -v '=' final_filtered_urls.txt > filtered_urls_without_params.txt  # Path URLs
        cat final_filtered_urls.txt | grep -E "\.php|\.asp|\.aspx|\.cfm|\.jsp" | sort > output_php_asp.txt
        grep -v "http[^ ]*\.[^/]*\." final_filtered_urls.txt | grep "http" | sort > clean_urls.txt

        # Run Arjun in passive mode in the background
        arjun --passive -i output_php_asp.txt -w ../../parameters.txt -oT arjun_passive.txt &

        # Run Arjun in active mode in the foreground
        arjun -i output_php_asp.txt -w ../../parameters.txt -t 20 -T 5 -oT arjun_active.txt

        # Wait for passive mode to complete (if not already finished)
        wait

        # Merge the results from passive and active scanning
        cat arjun_passive.txt arjun_active.txt | sort -u > arjun_params.txt

        # Merging all results into final_temp.txt
        cat filtered_urls_with_params.txt output_php_asp.txt clean_urls.txt arjun_params.txt >> final_urls.txt
        cat filtered_urls_without_params.txt clean_urls.txt >> potential_pathxss_urls.txt
    fi
    find -type f ! -name 'final_urls.txt' ! -name 'potential_pathxss_urls.txt' -delete
    cleanup_intermediate_files
}

# Function to clean up intermediate files (continuation)
cleanup_intermediate_files() {
    echo "[*] Cleaning up intermediate files and preparing final results..."

    if [ -f "final_clean.txt" ]; then
        echo "[*] final_clean.txt already exists, skipping."
    else
        # Apply gf patterns and prepare final files
        cat final_urls.txt | gf xss | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u > xss.txt
        cat final_urls.txt | gf sqli | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u > sqli.txt
        #cat final_urls.txt | gf ssrf | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u > ssrf.txt
        #cat final_urls.txt | gf ssti | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u > ssti.txt
        #cat final_urls.txt | gf urlparams | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u > urlparams.txt
        #cat final_urls.txt | gf redirect | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u > redirect.txt
        #cat final_urls.txt | gf idor | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u > idor.txt
        #cat final_urls.txt | gf lfi | sed 's/=.*/=/' | sed 's/URL: //' | uniq | sort -u > lfi.txt

        # Final merging of the files into one
        cat xss.txt sqli.txt | uniq | sort -u > final.txt
        find -type f ! -name 'final.txt' -delete
        
        # Run the second tools and update final clean
        subfinder -d $domain -all -silent | httpx-toolkit > subfinderdomain.txt
        bash ../../xsscrawler.sh -l subfinderdomain.txt -o secondtool.txt
        rm subfinderdomain.txt

        # Final clean preparation
        cat *.txt | uniq | sort -u > kontol.txt
        cat kontol.txt | sed -e 's/:80//g' > final_clean.txt
        #cat memek.txt | sed 's/^.*://' > 
    fi

    # After all processes, change back to the original directory
    cd "$original_dir"
    # Clean up all intermediate files but keep final.txt and domains.txt
    find output/$domain/ -type f ! -name 'final_clean.txt'  -delete
    # Run XSS scanners after cleanup
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

#Function to try sql injection
try_sqli() {
    echo "[*] Running SQLi testing..."
    
    # Run sqli
    python3 sqli.py -l output/$domain/final_clean.txt --payload payloadsqli.txt --rua
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
    echo "2. Check tools installation and permissions"
    echo "3. Enter a domain and start process XSS scanner"
    echo "4. Try Sql Injection Testing"
    echo "5. Quit"

    read -p "Select an option: " option

    case $option in
        1) install_tools ;;
        2) check_tools ;;
        3) prompt_domain_and_proceed ;;
        4) try_sqli ;;
        5) quit_and_clear_terminal ;;
        *) echo "Invalid option." ;;
    esac
done
