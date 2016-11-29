# == Schema Information
#
# Table name: actors
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: movies
#
#  id          :integer      not null, primary key
#  title       :string
#  yr          :integer
#  score       :float
#  votes       :integer
#  director_id :integer
#
# Table name: castings
#
#  movie_id    :integer      not null, primary key
#  actor_id    :integer      not null, primary key
#  ord         :integer

require_relative './sqlzoo.rb'

def example_join
  execute(<<-SQL)
    SELECT
      *
    FROM
      movies
    JOIN
      castings ON movies.id = castings.movie_id
    JOIN
      actors ON castings.actor_id = actors.id
    WHERE
      actors.name = 'Sean Connery'
  SQL
end

def ford_films
  # List the films in which 'Harrison Ford' has appeared.
  execute(<<-SQL)
  SELECT
    movies.title
  FROM
    movies
  JOIN castings
    ON movies.id = castings.movie_id
  JOIN actors
    ON castings.actor_id = actors.id
  WHERE
    actors.name = 'Harrison Ford'
  SQL
end

def ford_supporting_films
  # List the films where 'Harrison Ford' has appeared - but not in the star
  # role. [Note: the ord field of casting gives the position of the actor. If
  # ord=1 then this actor is in the starring role]
  execute(<<-SQL)
  SELECT
    movies.title
  FROM
    movies
  JOIN castings
    ON movies.id = castings.movie_id
  JOIN actors
    ON castings.actor_id = actors.id
  WHERE
    actors.name = 'Harrison Ford' AND castings.ord > 1
  SQL
end

def films_and_stars_from_sixty_two
  # List the title and leading star of every 1962 film.
  execute(<<-SQL)
  SELECT
    movies.title, actors.name
  FROM
    movies
  JOIN castings
    ON movies.id = castings.movie_id
  JOIN actors
    ON castings.actor_id = actors.id
  WHERE
    movies.yr = 1962 AND castings.ord = 1
  SQL
end

def travoltas_busiest_years
  # Which were the busiest years for 'John Travolta'? Show the year and the
  # number of movies he made for any year in which he made at least 2 movies.
  execute(<<-SQL)
  SELECT
    travolta_movies.yr, COUNT(travolta_movies.title)
  FROM (
    SELECT
      movies.yr, movies.title
    FROM
      movies
    JOIN castings
      ON movies.id = castings.movie_id
    JOIN actors
      ON castings.actor_id = actors.id
    WHERE
      actors.name = 'John Travolta'
    ) AS travolta_movies
  GROUP BY
    travolta_movies.yr
  HAVING
    COUNT(travolta_movies.title) >= 2
  SQL
end

def andrews_films_and_leads
  # List the film title and the leading actor for all of the films 'Julie
  # Andrews' played in.
  execute(<<-SQL)
  SELECT
    andrews_movies.title, actors.name
  FROM (
    SELECT
      movies.yr, movies.title, movies.id
    FROM
      movies
    JOIN castings
      ON movies.id = castings.movie_id
    JOIN actors
      ON castings.actor_id = actors.id
    WHERE
      actors.name = 'Julie Andrews'
    ) AS andrews_movies
  JOIN castings
    ON andrews_movies.id = castings.movie_id
  JOIN actors
    ON castings.actor_id = actors.id
  WHERE castings.ord = 1
  SQL
end

def prolific_actors
  # Obtain a list in alphabetical order of actors who've had at least 15
  # starring roles.
  execute(<<-SQL)
  SELECT
    star_actors.name
  FROM (
    SELECT
      actors.name, COUNT(actors.name)
    FROM
      actors
    JOIN castings
      ON actors.id = castings.actor_id
    JOIN movies
      ON castings.movie_id = movies.id
    WHERE
      castings.ord = 1
    GROUP BY
      actors.name
    HAVING
      COUNT(actors.name) >= 15
    ) AS star_actors
  ORDER BY star_actors.name
  SQL
end

def films_by_cast_size
  # List the films released in the year 1978 ordered by the number of actors
  # in the cast (descending), then by title (ascending).
  execute(<<-SQL)
  SELECT
    movies_1978.title, COUNT(*) AS cast_size
  FROM (
    SELECT
      movies.title, movies.id
    FROM
      movies
    WHERE
      movies.yr = 1978
    ) AS movies_1978
  JOIN castings
    ON movies_1978.id = castings.movie_id
  GROUP BY
    movies_1978.title
  ORDER BY
    cast_size DESC, movies_1978.title
  SQL
end

def colleagues_of_garfunkel
  # List all the people who have played alongside 'Art Garfunkel'.
  execute(<<-SQL)
  SELECT
    actors.name
  FROM
    actors
  JOIN castings
    ON actors.id = castings.actor_id
  JOIN (
    SELECT
      movies.id AS garfunkel_movie_id
    FROM
      movies
    JOIN castings
      ON movies.id = castings.movie_id
    JOIN actors
      ON castings.actor_id = actors.id
    WHERE
      actors.name = 'Art Garfunkel'
  ) AS garfunkel_movies
  ON castings.movie_id = garfunkel_movies.garfunkel_movie_id
  WHERE actors.name != 'Art Garfunkel'
  ORDER BY
    actors.name
  SQL
end
