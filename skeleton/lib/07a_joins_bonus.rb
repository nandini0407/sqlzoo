# == Schema Information
#
# Table name: albums
#
#  asin        :string       not null, primary key
#  title       :string
#  artist      :string
#  price       :float
#  rdate       :date
#  label       :string
#  rank        :integer
#
# Table name: styles
#
# album        :string       not null
# style        :string       not null
#
# Table name: tracks
# album        :string       not null
# disk         :integer      not null
# posn         :integer      not null
# song         :string

require_relative './sqlzoo.rb'

def alison_artist
  # Select the name of the artist who recorded the song 'Alison'.
  execute(<<-SQL)
    select
      artist
    from
      albums
    join
      tracks on albums.asin = tracks.album
    where
      tracks.song= 'Alison'
  SQL
end

def exodus_artist
  # Select the name of the artist who recorded the song 'Exodus'.
  execute(<<-SQL)
    select albums.artist
    from
      albums
    join
      tracks on albums.asin = tracks.album
    where
      tracks.song = 'Exodus'
  SQL
end

def blur_songs
  # Select the `song` for each `track` on the album `Blur`.
  execute(<<-SQL)
    select tracks.song
    from
      tracks
    join
      albums on tracks.album = albums.asin
    where
      albums.title = 'Blur'
  SQL
end

def heart_tracks
  # For each album show the title and the total number of tracks containing
  # the word 'Heart' (albums with no such tracks need not be shown). Order first by
  # the number of such tracks, then by album title.
  execute(<<-SQL)
    select
      albums.title, count(*) as total
    from
      albums
    join
      tracks on albums.asin = tracks.album
    where
      tracks.song like '%Heart%'
    group by
      albums.title
    order by
      total desc, albums.title
  SQL
end

def title_tracks
  # A 'title track' has a `song` that is the same as its album's `title`. Select
  # the names of all the title tracks.
  execute(<<-SQL)
    select tracks.song
    from
      tracks
    join
      albums on tracks.album = albums.asin
    where
      tracks.song = albums.title
  SQL
end

def eponymous_albums
  # An 'eponymous album' has a `title` that is the same as its recording
  # artist's name. Select the titles of all the eponymous albums.
  execute(<<-SQL)
    select
      albums.title
    from
      albums
    where
      albums.title = albums.artist
  SQL
end

def song_title_counts
  # Select the song names that appear on more than two albums. Also select the
  # COUNT of times they show up.
  execute(<<-SQL)
    select
      tracks.song, count(distinct albums.asin)
    from
      tracks
    join
      albums on tracks.album = albums.asin
    group by
      tracks.song
    having count(distinct albums.asin) > 2
  SQL
end

def best_value
  # A "good value" album is one where the price per track is less than 50
  # pence. Find the good value albums - show the title, the price and the number
  # of tracks.
  execute(<<-SQL)
    select
      albums.title, albums.price, count(tracks.song)
    from
      albums
    join
      tracks on albums.asin = tracks.album
    group by
      albums.title, albums.price
    having
      (albums.price / count(tracks.song)) < 0.5
  SQL
end

def top_track_counts
  # Wagner's Ring cycle has an imposing 173 tracks, Bing Crosby clocks up 101
  # tracks. List the top 10 albums. Select both the album title and the track
  # count, and order by both track count and title (descending).
  execute(<<-SQL)
    select
      albums.title, count(tracks.*)
    from
      albums
    join
      tracks on albums.asin = tracks.album
    group by
      albums.title
    order by
      count(tracks.*) desc, albums.title desc
    limit 10
  SQL
end

def rock_superstars
  # Select the artist who has recorded the most rock albums, as well as the
  # number of albums. HINT: use LIKE '%Rock%' in your query.
  execute(<<-SQL)
    select
      albums.artist, count(distinct albums.asin)
    from
      albums
    join
      styles on albums.asin = styles.album
    where
      styles.style like '%Rock%'
    group by
      albums.artist
    order by
      count(distinct albums.asin) desc
    limit 1
  SQL
end

def expensive_tastes
  # Select the five styles of music with the highest average price per track,
  # along with the price per track. One or more of each aggregate functions,
  # subqueries, and joins will be required.
  #
  # HINT: Start by getting the number of tracks per album. You can do this in a
  # subquery. Next, JOIN the styles table to this result and use aggregates to
  # determine the average price per track.
  execute(<<-SQL)
    select
      styles.style, (sum(album_songs.price) / sum(count)) as avg_price
    from
      styles
    join (
      select
        albums.*, count(tracks.song) as count
      from
        albums
      join
        tracks on albums.asin = tracks.album
      where
        albums.price is not null
      group by
        albums.asin
      ) as album_songs
    on styles.album = album_songs.asin
    group by
      styles.style
    order by
      avg_price desc
    limit 5
  SQL
end
