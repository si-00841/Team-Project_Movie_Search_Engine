'''
Created on 2025. 4. 16.

@author: 정세훈
'''
# 데이터 추출

import requests
from elasticsearch import Elasticsearch

# 1. TMDB에서 데이터 가져와서 변수 설정
TMDB_API_KEY = "53b55dbc42867a260801659e03e38866"
TMDB_API_URL = "https://api.themoviedb.org/3/discover/movie"

def fetch_tmdb_movies(page=1):                             # 1페이지의 데이터 가져옴
    params = {                                             # API 요청에 필요한 파라미터(인증키, 페이지 번호)를 딕셔너리 형태로 설정
        "api_key" : TMDB_API_KEY,
        "page" : page
        }
    response = requests.get(TMDB_API_URL, params = params) # HTTP GET 요청을 보내고, 응답을 받아옵
    response.raise_for_status()                            # 요청이 실패하면 예외를 발생시켜 중단
    return response.json()["results"]                      # 응답 결과를 JSON형태로 파싱하고, 그 중 results 배열(영화 리스트)만 반환

# 2. 연결 및 저장
es = Elasticsearch("http://localhost:9200")
index_name = "tmdb-movies"

def save_to_elasticsearch(movies):
    for movie in movies:
        # release_date가 비어 있으면 None으로 설정
        if 'release_date' in movie and movie['release_date'] == '':
            movie['release_date'] = None
        es.index(index = index_name, body = movie)

# 전체 실행 로직 (반복문을 통해 변수 page의 값을 1씩 늘리면서 1~2 코드의 반복을 통해 여러 페이지의 데이터를 가져와서 저장함)
if __name__ == "__main__":
    page = 1
    while True:
        print(f"Fetching page {page}")
        movies = fetch_tmdb_movies(page = page)
        
        # 더 이상 가져올 데이터가 없으면 종료
        if not movies:
            print("더 이상 가져올 데이터가 없습니다.")
            break
        
        save_to_elasticsearch(movies)
        page += 1
        
