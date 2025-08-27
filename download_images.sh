#!/bin/bash
# Infinite Challenge 교재 이미지 다운로드 스크립트

BASE_URL="https://infinitechallenge.ca"
BASE_DIR="assets/images/books"

# 교재 정보 배열
declare -A BOOKS=(
    ["calculus_12"]="Calculus 12|calculus-12-|28"
    ["calculus_bc"]="Calculus BC|calculus-bc-|28" 
    ["ap_calculus"]="AP Calculus|ap-calculcus/|28"
    ["pre_calculus"]="Pre-Calculus|pre|28"
    ["pre_calculus_10"]="Pre-Calculus 10|pre10-|28"
)

echo "🚀 Infinite Challenge 교재 이미지 다운로드를 시작합니다..."

# 전체 다운로드된 이미지 수
total_downloaded=0

for book_key in "${!BOOKS[@]}"; do
    IFS='|' read -r book_name pattern count <<< "${BOOKS[$book_key]}"
    
    echo ""
    echo "📚 Downloading $book_name images..."
    
    # 디렉토리 생성
    mkdir -p "$BASE_DIR/$book_key/thumbnails"
    mkdir -p "$BASE_DIR/$book_key/full"
    
    downloaded_count=0
    
    # 각 페이지 이미지 다운로드
    for i in $(seq 1 $count); do
        # 썸네일 다운로드
        if [[ "$pattern" == *"ap-calculcus"* ]]; then
            thumb_url="$BASE_URL/images/$pattern/thumb/$i.jpg"
            full_url="$BASE_URL/images/$pattern/$i.jpg"
        else
            thumb_url="$BASE_URL/images/thumb/$pattern$i.jpg"
            full_url="$BASE_URL/images/$pattern$i.jpg"
        fi
        
        thumb_path="$BASE_DIR/$book_key/thumbnails/page_$(printf %02d $i).jpg"
        full_path="$BASE_DIR/$book_key/full/page_$(printf %02d $i).jpg"
        
        # 썸네일 다운로드
        if curl -s -o "$thumb_path" "$thumb_url"; then
            if [ -s "$thumb_path" ]; then
                size=$(wc -c < "$thumb_path")
                echo "✓ Downloaded thumbnail: page_$(printf %02d $i).jpg ($size bytes)"
                ((downloaded_count++))
            else
                echo "✗ Failed to download thumbnail: $thumb_url (empty file)"
                rm -f "$thumb_path"
            fi
        else
            echo "✗ Failed to download thumbnail: $thumb_url"
        fi
        
        # 풀사이즈 다운로드
        if curl -s -o "$full_path" "$full_url"; then
            if [ -s "$full_path" ]; then
                size=$(wc -c < "$full_path")
                echo "✓ Downloaded full: page_$(printf %02d $i).jpg ($size bytes)"
            else
                echo "✗ Failed to download full: $full_url (empty file)"
                rm -f "$full_path"
            fi
        else
            echo "✗ Failed to download full: $full_url"
        fi
        
        # 서버 과부하 방지
        sleep 0.3
    done
    
    # 메타데이터 생성
    cat > "$BASE_DIR/$book_key/metadata.json" << EOF
{
  "book_info": {
    "name": "$book_name",
    "description": "$book_name 교재",
    "total_pages": $count
  },
  "downloaded_at": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
  "total_pages": $downloaded_count,
  "assets_path": "assets/images/books/$book_key"
}
EOF
    
    echo "✅ $book_name: $downloaded_count pages downloaded"
    ((total_downloaded += downloaded_count))
done

# 전체 인덱스 파일 생성
cat > "$BASE_DIR/index.json" << 'EOF'
{
  "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
  "books": {
    "calculus_12": {
      "name": "Calculus 12",
      "description": "Calculus 12 교재",
      "total_pages": 28,
      "assets_path": "assets/images/books/calculus_12"
    },
    "calculus_bc": {
      "name": "Calculus BC", 
      "description": "Calculus BC 교재",
      "total_pages": 28,
      "assets_path": "assets/images/books/calculus_bc"
    },
    "ap_calculus": {
      "name": "AP Calculus",
      "description": "AP Calculus 교재", 
      "total_pages": 28,
      "assets_path": "assets/images/books/ap_calculus"
    },
    "pre_calculus": {
      "name": "Pre-Calculus",
      "description": "Pre-Calculus 교재",
      "total_pages": 28, 
      "assets_path": "assets/images/books/pre_calculus"
    },
    "pre_calculus_10": {
      "name": "Pre-Calculus 10",
      "description": "Pre-Calculus 10 교재",
      "total_pages": 28,
      "assets_path": "assets/images/books/pre_calculus_10"
    }
  }
}
EOF

echo ""
echo "📋 Created book index: $BASE_DIR/index.json" 
echo "🎉 완료! 총 $total_downloaded개 페이지의 이미지가 다운로드되었습니다."
echo "Flutter 프로젝트의 $BASE_DIR/ 디렉토리를 확인하세요."