'''
Created on 2025. 4. 16.

@author: 정세훈
'''
# 10,000건 이상일 때

from elasticsearch import Elasticsearch
from deep_translator import GoogleTranslator # 설치 필요 - pip install deep-translator, Papago API 또는 ChatGPT API로 대체 가능  
from uuid import uuid4

# 번역기 준비
es = Elasticsearch("http://localhost:9200")
translator = GoogleTranslator(source = 'auto', target = 'ko')

# 새 인덱스 생성
if not es.indices.exists(index = "tmdb-movies-ko"):
    es.indices.create(index = "tmdb-movies-ko")

# 최초 scroll 요청, 엘라스틱서치에서 데이터 불러오기, _source 부분만 번역
scroll_time = "2m"
response = es.search(index="tmdb-movies", scroll = scroll_time, body = {"query" : {"match_all": {}}}, size=1000)
scroll_id = response["_scroll_id"]
hits = response["hits"]["hits"]

batch_num = 0
total_saved = 0

# scroll 반복
while hits:
    print(f"[Batch {batch_num}] 처리 시작 - 문서 수: {len(hits)}")
    for hit in hits:
        movie = hit["_source"]
        translated = movie.copy()
        
        try:
            translated["original_language_ko"] = translator.translate(movie.get("original_language", ""))
            translated["overview_ko"] = translator.translate(movie.get("overview", ""))
            translated["title_ko"] = translator.translate(movie.get("title", ""))
            
            es.index(index="tmdb-movies-ko", body=translated, id=str(uuid4()))
            total_saved += 1
            
        except Exception as e:
            print(f"[오류] 번역 실패: {e}")
            continue
    
    batch_num += 1
    print(f"[Batch {batch_num}] 배치 처리 완료 - 총 저장된 문서 수: {total_saved}건")
    
    # 다음 페이지 요청
    response = es.scroll(scroll_id = scroll_id, scroll = scroll_time)
    scroll_id = response["_scroll_id"]
    hits = response["hits"]["hits"]

# scroll context 종료
es.clear_scroll(scroll_id=scroll_id)
print(f"모든 문서 번역 및 저장 완료: 총 {total_saved}건 저장됨")



    