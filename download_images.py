#!/usr/bin/env python3
"""
Infinite Challenge 교재 이미지 다운로드 스크립트
infinitechallenge.ca에서 수학 교재 이미지들을 다운로드합니다.
"""

import os
import requests
from urllib.parse import urljoin
import time
import json
from datetime import datetime

# 기본 URL 설정
BASE_URL = "https://infinitechallenge.ca/"

# 교재별 이미지 정보
BOOKS = {
    "ap_calculus": {
        "name": "AP Calculus",
        "description": "Advanced Placement Calculus 교재",
        "thumbnail_pattern": "images/ap-calculcus/thumb/{}.jpg",  # 원본 사이트 오타 그대로
        "full_pattern": "images/ap-calculcus/{}.jpg",
        "count": 28
    },
    "calculus_bc": {
        "name": "Calculus BC",
        "description": "Calculus BC 교재",
        "thumbnail_pattern": "images/thumb/calculus-bc-{}.jpg",
        "full_pattern": "images/calculus-bc-{}.jpg",
        "count": 28
    },
    "calculus_12": {
        "name": "Calculus 12", 
        "description": "Calculus 12 교재",
        "thumbnail_pattern": "images/thumb/calculus-12-{}.jpg",
        "full_pattern": "images/calculus-12-{}.jpg",
        "count": 28
    },
    "pre_calculus": {
        "name": "Pre-Calculus",
        "description": "Pre-Calculus 교재", 
        "thumbnail_pattern": "images/thumb/pre{}.jpg",
        "full_pattern": "images/pre{}.jpg",
        "count": 28
    },
    "pre_calculus_10": {
        "name": "Pre-Calculus 10",
        "description": "Pre-Calculus 10 교재",
        "thumbnail_pattern": "images/thumb/pre10-{}.jpg", 
        "full_pattern": "images/pre10-{}.jpg",
        "count": 28
    }
}

def download_image(url, filepath, session):
    """이미지를 다운로드하고 저장합니다."""
    try:
        response = session.get(url, timeout=30)
        if response.status_code == 200:
            os.makedirs(os.path.dirname(filepath), exist_ok=True)
            with open(filepath, 'wb') as f:
                f.write(response.content)
            print(f"✓ Downloaded: {os.path.basename(filepath)} ({len(response.content)} bytes)")
            return True
        else:
            print(f"✗ Failed to download {url}: HTTP {response.status_code}")
            return False
    except Exception as e:
        print(f"✗ Error downloading {url}: {e}")
        return False

def download_book_images(book_key, book_info, base_dir="assets/images/books"):
    """특정 교재의 모든 이미지를 다운로드합니다."""
    print(f"\n📚 Downloading {book_info['name']} images...")
    
    session = requests.Session()
    session.headers.update({
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
    })
    
    # 디렉토리 생성
    thumb_dir = os.path.join(base_dir, book_key, "thumbnails")
    full_dir = os.path.join(base_dir, book_key, "full")
    
    downloaded_images = []
    
    # 각 페이지 이미지 다운로드
    for i in range(1, book_info['count'] + 1):
        # 썸네일 다운로드
        thumb_url = urljoin(BASE_URL, book_info['thumbnail_pattern'].format(i))
        thumb_path = os.path.join(thumb_dir, f"page_{i:02d}.jpg")
        
        if download_image(thumb_url, thumb_path, session):
            downloaded_images.append({
                "page": i,
                "thumbnail": thumb_path,
                "thumbnail_url": thumb_url
            })
        
        # 풀사이즈 다운로드
        full_url = urljoin(BASE_URL, book_info['full_pattern'].format(i))
        full_path = os.path.join(full_dir, f"page_{i:02d}.jpg")
        
        if download_image(full_url, full_path, session):
            if downloaded_images and downloaded_images[-1]['page'] == i:
                downloaded_images[-1]['full'] = full_path
                downloaded_images[-1]['full_url'] = full_url
        
        # 서버 과부하 방지를 위한 딜레이
        time.sleep(0.5)
    
    # 메타데이터 저장
    metadata = {
        "book_info": book_info,
        "downloaded_at": datetime.now().isoformat(),
        "total_pages": len(downloaded_images),
        "images": downloaded_images
    }
    
    metadata_path = os.path.join(base_dir, book_key, "metadata.json")
    os.makedirs(os.path.dirname(metadata_path), exist_ok=True)
    with open(metadata_path, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)
    
    print(f"✅ {book_info['name']}: {len(downloaded_images)} pages downloaded")
    return downloaded_images

def create_book_index():
    """전체 교재 목록 인덱스를 생성합니다."""
    index = {
        "generated_at": datetime.now().isoformat(),
        "books": {}
    }
    
    for book_key, book_info in BOOKS.items():
        index["books"][book_key] = {
            "name": book_info["name"],
            "description": book_info["description"], 
            "total_pages": book_info["count"],
            "assets_path": f"assets/images/books/{book_key}"
        }
    
    with open("assets/images/books/index.json", 'w', encoding='utf-8') as f:
        json.dump(index, f, indent=2, ensure_ascii=False)
    
    print("📋 Created book index: assets/images/books/index.json")

def main():
    """메인 실행 함수"""
    print("🚀 Infinite Challenge 교재 이미지 다운로드를 시작합니다...")
    
    # 모든 교재 이미지 다운로드
    total_downloaded = 0
    for book_key, book_info in BOOKS.items():
        images = download_book_images(book_key, book_info)
        total_downloaded += len(images)
    
    # 인덱스 파일 생성
    create_book_index()
    
    print(f"\n🎉 완료! 총 {total_downloaded}개 페이지의 이미지가 다운로드되었습니다.")
    print("Flutter 프로젝트의 assets/images/books/ 디렉토리를 확인하세요.")

if __name__ == "__main__":
    main()