domain=$1
RED="\033[1;31m"
RESET="\033[0m"

info_path=$domain/info
subdomain_path=$domain/subdomains
screenshot_path=$domain/screenshots

if [ "$#" -ne 1 ];then
    echo "\nUSAGE :\n./autoOSINT.sh [domain name]\n\nEXAMPLE :\n./autoOSINT.sh abcd.com"
    exit 0
fi

if [ ! -d "$domain" ];then
    mkdir $domain
fi

if [ ! -d "$info_path" ];then
    mkdir $info_path
fi

if [ ! -d "$subdomain_path" ];then
    mkdir $subdomain_path
fi

if [ ! -d "$screenshot_path" ];then
    mkdir $screenshot_path
fi

echo "${RED} [+] Checkin' who it is...${RESET}"
whois $1 > $info_path/whois.txt 2>&1

echo "${RED} [+] Launching subfinder...${RESET}"
subfinder -d $domain > $subdomain_path/found.txt 2>&1

echo "${RED} [+] Running assetfinder...${RESET}"
assetfinder $domain | grep $domain >> $subdomain_path/found.txt 2>&1

echo "${RED} [+] Running Amass. This could take a while...${RESET}"
amass enum -d $domain >> $subdomain_path/found.txt

echo "${RED} [+] Checking what's alive...${RESET}"
cat $subdomain_path/found.txt | grep $domain | sort -u | httprobe -s -p https:443 | grep https | sed 's/https\?:\/\///' | tee -a $subdomain_path/alive.txt

echo "${RED} [+] Taking dem screenshotz...${RESET}"
gowitness file -f $subdomain_path/alive.txt -P $screenshot_path/ --no-http
