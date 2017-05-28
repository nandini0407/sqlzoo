# == Schema Information
#
# Table name: countries
#
#  name        :string       not null, primary key
#  continent   :string
#  area        :integer
#  population  :integer
#  gdp         :integer

require_relative './sqlzoo.rb'

# BONUS QUESTIONS: These problems require knowledge of aggregate
# functions. Attempt them after completing section 05.

def highest_gdp
  # Which countries have a GDP greater than every country in Europe? (Give the
  # name only. Some countries may have NULL gdp values)
  execute(<<-SQL)
    select name
    from countries
    where gdp is not null and gdp > (
      select
        max(gdp)
      from
        countries
      where
        continent = 'Europe'
    )
  SQL
end

def largest_in_continent
  # Find the largest country (by area) in each continent. Show the continent,
  # name, and area.
  execute(<<-SQL)
    select
      a.continent, a.name, a.area
    from
      countries as a
    join (
      select
        continent, max(area) as max_area
      from
        countries
      group by
        continent
    ) as b on a.continent = b.continent and a.area = b.max_area
  SQL
end

def large_neighbors
  # Some countries have populations more than three times that of any of their
  # neighbors (in the same continent). Give the countries and continents.
  execute(<<-SQL)
    select
      a.name, a.continent
    from
      countries as a
    where
      a.population > 3 * (
        select
          max(b.population)
        from
          countries as b
        where
          a.continent = b.continent and a.name != b.name
        group by
          continent
      )
  SQL
end
