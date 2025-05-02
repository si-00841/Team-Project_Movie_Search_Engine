<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>영화 사이트</title>
<style>
  /* 스타일링 부분은 원하는 대로 추가해 주세요 */
</style>
</head>
<body>
  <h1>🎬 인기 영화</h1>
  <input type="text" id="search" placeholder="영화 검색..." />

  <div id="movie-list"></div>

  <script>
    const API_KEY = '여기에_본인의_API_키_입력';  // TMDb API 키
    let moviesFromAPI = [];  // 영화 데이터를 저장할 전역 변수

    // 영화 목록을 화면에 표시하는 함수
    const displayMovies = (movies) => {
      const movieList = document.getElementById('movie-list');
      movieList.innerHTML = '';  // 기존 영화 목록을 초기화

      movies.forEach(movie => {
        const card = document.createElement('div');
        card.className = 'movie-card';

        card.innerHTML = `
          <img src="${movie.image}" alt="${movie.title}" />
          <div class="movie-info">
            <div class="movie-title">${movie.title}</div>
            <div class="movie-rating">⭐ 평점: ${movie.rating} / 5</div>
            <div class="movie-release">개봉연도: ${movie.releaseYear}</div>
          </div>
        `;

        // 클릭 시 상세 페이지로 이동하는 기능 추가
        card.addEventListener('click', () => {
          window.location.href = `movie_details.html?id=${movie.id}`;
        });

        movieList.appendChild(card);  // 영화 카드를 화면에 추가
      });
    };

    // TMDb API로 영화 목록 가져오기
    fetch(`https://api.themoviedb.org/3/movie/popular?api_key=${API_KEY}`)
      .then(response => response.json())
      .then(data => {
        // API에서 받은 데이터를 영화 카드에 표시할 형태로 변환
        moviesFromAPI = data.results.map(movie => ({
          title: movie.title,
          rating: movie.vote_average,
          releaseYear: movie.release_date.split('-')[0],
          image: `https://image.tmdb.org/t/p/w500${movie.poster_path}`,
          id: movie.id
        }));

        // 영화 목록을 화면에 표시
        displayMovies(moviesFromAPI);
      })
      .catch(error => console.error("Error fetching data: ", error));

    // 검색 기능 구현
    const searchInput = document.getElementById('search');
    searchInput.addEventListener('input', (e) => {
      const query = e.target.value.toLowerCase();  // 입력된 검색어 소문자로 변환
      // 제목에 검색어가 포함되는 영화만 필터링
      const filteredMovies = moviesFromAPI.filter(movie => 
        movie.title.toLowerCase().includes(query)
      );
      displayMovies(filteredMovies);  // 필터링된 영화 목록을 화면에 표시
    });
  </script>
</body>
</html>
