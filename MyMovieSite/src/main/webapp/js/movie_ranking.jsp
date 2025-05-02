<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>영화 랭킹</title>
  <style>
    body {
      font-family: sans-serif;
      background: #f0f0f0;
      padding: 20px;
    }
    h1 {
      color: #333;
    }
    .movie-card {
      background: white;
      padding: 15px;
      margin: 15px 0;
      border-radius: 10px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      display: flex;
      gap: 15px;
      align-items: center;
    }
    .movie-card img {
      width: 100px;
      border-radius: 8px;
    }
    .movie-info {
      display: flex;
      flex-direction: column;
    }
  </style>
</head>
<body>

<h1>🎬 TMDb 인기 영화</h1>

<div id="movie-container">영화 데이터를 불러오는 중...</div>

<script>
  const API_KEY = "53b55dbc42867a260801659e03e38866";

  async function fetchMovies() {
    try {
      const response = await fetch(`https://api.themoviedb.org/3/movie/popular?api_key=${API_KEY}&language=ko`);
      if (!response.ok) throw new Error("API 호출 실패");

      const data = await response.json();
      const movies = data.results;

      const container = document.getElementById('movie-container');
      container.innerHTML = '';

      movies.forEach(movie => {
        const card = document.createElement('div');
        card.className = 'movie-card';

        card.innerHTML = `
          <img src="https://image.tmdb.org/t/p/w500${movie.poster_path}" alt="${movie.title}">
          <div class="movie-info">
            <strong>${movie.title}</strong>
            <span>⭐ 평점: ${movie.vote_average}</span>
            <span>📅 개봉일: ${movie.release_date}</span>
          </div>
        `;
        container.appendChild(card);
      });

    } catch (err) {
      console.error("오류 발생:", err);
      document.getElementById('movie-container').innerHTML = "<p style='color:red;'>API 호출에 실패했습니다. 잠시 후 다시 시도해주세요.</p>";
    }
  }

  window.onload = fetchMovies;
</script>

</body>
</html>
