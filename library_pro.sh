#!/bin/bash

# ==============================================================================
# PROJECT: Professional Library Management System
# SYLLABUS MAPPING: 
#   - Text Processing (grep, awk, cut) [Practical 2, 4]
#   - File Handling & Redirection [Unit 2, 5]
#   - Shell Programming (loops, case, functions) [Unit 5]
# ==============================================================================

# --- DATABASE CONFIGURATION ---
BOOK_DB="books.txt"       # Format: ID|Title|Author|Stock
STUDENT_DB="students.txt" # Format: PRN|Name|Department
LOG_FILE="transactions.log" # Format: Timestamp|PRN|BookID|Type

# --- COLORS FOR UI ---
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- INITIALIZATION ---
init_system() {
    # Create files if missing (File Handling)
    if [ ! -f "$BOOK_DB" ]; then
        echo "101|Linux Fundamentals|Jason Cannon|5" > "$BOOK_DB"
        echo "102|The Linux Command Line|William Shotts|3" >> "$BOOK_DB"
    fi
    if [ ! -f "$STUDENT_DB" ]; then
        echo "1001|Pranav Mhasaye|CompEng" > "$STUDENT_DB"
        echo "1002|Rahul Patil|MechEng" >> "$STUDENT_DB"
    fi
    touch "$LOG_FILE"
    chmod 664 "$BOOK_DB" "$STUDENT_DB" "$LOG_FILE"
}

# --- 1. ISSUE BOOK ---
issue_book() {
    echo -e "\n${CYAN}--- ISSUE BOOK ---${NC}"
    read -p "Scan PRN: " prn
    
    # Check if student exists (grep)
    if ! grep -q "^$prn|" "$STUDENT_DB"; then
        echo -e "${RED}Error: Student PRN not found!${NC}"
        return
    fi
    
    read -p "Scan Book ID: " bid
    book_line=$(grep "^$bid|" "$BOOK_DB")
    
    if [ -z "$book_line" ]; then
        echo -e "${RED}Error: Book ID not found!${NC}"
        return
    fi

    # Extract stock (cut) and update
    current_stock=$(echo "$book_line" | cut -d'|' -f4)
    if [ "$current_stock" -gt 0 ]; then
        new_stock=$((current_stock - 1))
     :  
        # Update using temp file (Text Processing)
        grep -v "^$bid|" "$BOOK_DB" > temp.db
        echo "$bid|$(echo "$book_line" | cut -d'|' -f2,3)|$new_stock" >> temp.db
        sort temp.db > "$BOOK_DB"
        rm temp.db
        
        # Log Transaction
        echo "$(date "+%Y-%m-%d %H:%M:%S")|$prn|$bid|ISSUE" >> "$LOG_FILE"
        echo -e "${GREEN}Success: Book Issued.${NC}"
    else
        echo -e "${RED}Out of Stock!${NC}"
    fi
}

# --- 2. RETURN BOOK ---
return_book() {
    echo -e "\n${CYAN}--- RETURN BOOK ---${NC}"
    read -p "Scan Book ID: " bid
    
    book_line=$(grep "^$bid|" "$BOOK_DB")
    if [ -z "$book_line" ]; then
        echo -e "${RED}Invalid Book ID.${NC}"
        return
    fi

    # Increment Stock
    current_stock=$(echo "$book_line" | cut -d'|' -f4)
    new_stock=$((current_stock + 1))
    
    grep -v "^$bid|" "$BOOK_DB" > temp.db
    echo "$bid|$(echo "$book_line" | cut -d'|' -f2,3)|$new_stock" >> temp.db
    sort temp.db > "$BOOK_DB"
    rm temp.db
    
    read -p "Scan PRN (for log): " prn
    echo "$(date "+%Y-%m-%d %H:%M:%S")|$prn|$bid|RETURN" >> "$LOG_FILE"
    echo -e "${GREEN}Success: Book Returned.${NC}"
}

# --- 3. LIST BOOKS WITH SEARCHING ---
list_search_books() {
    echo -e "\n${CYAN}--- BOOK CATALOG ---${NC}"
    echo "Leave empty to list all books."
    read -p "Search (Title/Author): " query
    
    echo -e "${YELLOW}ID   | Title                  | Author          | Stock${NC}"
    echo "--------------------------------------------------------"
    
    if [ -z "$query" ]; then
        # List all (awk for formatting)
        awk -F"|" '{printf "%-4s | %-22s | %-15s | %s\n", $1, $2, $3, $4}' "$BOOK_DB"
    else
        # Search specific
        grep -i "$query" "$BOOK_DB" | awk -F"|" '{printf "%-4s | %-22s | %-15s | %s\n", $1, $2, $3, $4}'
        
        # Check if empty result
        if [ $? -ne 0 ]; then
            echo -e "${RED}No matches found.${NC}"
        fi
    fi
}

# --- 4. ADD OR REMOVE BOOK ---
manage_books() {
    echo -e "\n${CYAN}--- MANAGE BOOKS ---${NC}"
    echo "1. Add New Book"
    echo "2. Remove Book"
    read -p "Choose: " sub_choice
    
    case $sub_choice in
        1)
            read -p "Enter New Book ID: " bid
            if grep -q "^$bid|" "$BOOK_DB"; then
                echo -e "${RED}ID already exists!${NC}"; return
            fi
            read -p "Title: " title
            read -p "Author: " author
            read -p "Stock: " stock
            echo "$bid|$title|$author|$stock" >> "$BOOK_DB"
            echo -e "${GREEN}Book Added.${NC}"
            ;;
        2)
            read -p "Enter Book ID to REMOVE: " bid
            if ! grep -q "^$bid|" "$BOOK_DB"; then
                echo -e "${RED}ID not found.${NC}"; return
            fi
            # grep -v excludes the line (removing it)
            grep -v "^$bid|" "$BOOK_DB" > temp.db && mv temp.db "$BOOK_DB"
            echo -e "${GREEN}Book Removed.${NC}"
            ;;
        *) echo "Invalid option." ;;
    esac
}

# --- 5. LIST STUDENTS WITH STATS ---
student_stats() {
    echo -e "\n${CYAN}--- REGISTERED STUDENTS & ACTIVITY ---${NC}"
    echo -e "${YELLOW}PRN    | Name                | Dept     | Transactions${NC}"
    echo "--------------------------------------------------------"
    
    # Read student DB line by line
    while IFS='|' read -r prn name dept; do
        # Count occurrences in log file (grep -c)
        count=$(grep -c "$prn" "$LOG_FILE")
        printf "%-6s | %-19s | %-8s | %s\n" "$prn" "$name" "$dept" "$count"
    done < "$STUDENT_DB"
}

# --- 6. VIEW TRANSACTIONS ---
view_transactions() {
    echo -e "\n${CYAN}--- TRANSACTION LOGS ---${NC}"
    echo -e "${YELLOW}Timestamp           | PRN    | BookID | Type${NC}"
    echo "---------------------------------------------------"
    # Display last 10 transactions
    tail -n 10 "$LOG_FILE" | awk -F"|" '{printf "%-19s | %-6s | %-6s | %s\n", $1, $2, $3, $4}'
}

# --- MAIN MENU ---
main_menu() {
    init_system
    while true; do
        echo -e "\n${CYAN}=== MITAOE LIBRARY SYSTEM ===${NC}"
        echo "1. Issue Book"
        echo "2. Return Book"
        echo "3. List Books (Search)"
        echo "4. Add/Remove Book"
        echo "5. Student Stats"
        echo "6. View Transactions"
        echo "7. Exit"
        read -p "Select Option (1-7): " choice
        
        case $choice in
            1) issue_book ;;
            2) return_book ;;
            3) list_search_books ;;
            4) manage_books ;;
            5) student_stats ;;
            6) view_transactions ;;
            7) exit 0 ;;
            *) echo "Invalid Option" ;;
        esac
    done
}

# Start
main_menu
