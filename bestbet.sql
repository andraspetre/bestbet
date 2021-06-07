--create bestbet table and commit it
CREATE TABLE bestbet
(
  my_date        DATE,
  game_id        TEXT,
  round_id       INTEGER,
  risked_money   BIGINT,
  expected_value FLOAT,
  multiplier     FLOAT,
  chance_of_winning FLOAT,
  did_they_win      BOOLEAN,
  how_munch         BIGINT,
  new_stack         BIGINT
);

COMMIT;

--how many games per day
SELECT my_date, COUNT(*)/50 as num_of_games FROM bestbet
GROUP BY my_date;

--avarage (mean) number of games per day
SELECT SUM(games_per_day.num_of_games)/COUNT(*) AS mean FROM
(SELECT my_date, COUNT(*) as num_of_games FROM bestbet
GROUP BY my_date) as games_per_day;

--How many games ended with the player losing (score went down to 0)?
SELECT * FROM bestbet
WHERE round_id = 50 AND new_stack = 0;

-- average stack per round
SELECT (SUBSTRING(game_id, 6))::INTEGER as game_only_id, SUM(new_stack)/50 as avarage_stack_per_round FROM bestbet 
GROUP BY game_id
ORDER BY game_only_id;


-- win ratio / day
SELECT wins.my_date, wins.wins, not_wins.not_wins, (wins.wins::FLOAT/(wins.wins+not_wins.not_wins::FLOAT))*100 as wins_percent FROM 
(SELECT my_date, COUNT(*) as wins FROM bestbet 
WHERE did_they_win = true
GROUP BY my_date) as wins
JOIN
(SELECT my_date, COUNT(*) as not_wins FROM bestbet 
WHERE did_they_win = false
GROUP BY my_date) as not_wins ON wins.my_date = not_wins.my_date; 

-- wins ratio / game
SELECT wins.game_only_id, (wins.wins::FLOAT/(wins.wins+not_wins.not_wins::FLOAT))*100 as wins_percent FROM
(SELECT (SUBSTRING(game_id, 6))::INTEGER as game_only_id, COUNT(*) as wins FROM bestbet
WHERE did_they_win = true
GROUP BY game_id
ORDER BY game_only_id) as wins
JOIN
(SELECT (SUBSTRING(game_id, 6))::INTEGER as game_only_id, COUNT(*) as not_wins FROM bestbet
WHERE did_they_win = false
GROUP BY game_id
ORDER BY game_only_id) as not_wins ON wins.game_only_id = not_wins.game_only_id;

-- wins/day stddev
SELECT my_date, STDDEV(how_much) as stddev_wins FROM bestbet
GROUP BY my_date;

-- wins/game stddev
SELECT (SUBSTRING(game_id, 6))::INTEGER as game_only_id, STDDEV(how_much) as stddev_wins FROM bestbet
GROUP BY game_only_id
ORDER BY game_only_id;

-- stack/game stdev
SELECT (SUBSTRING(game_id, 6))::INTEGER as game_only_id, STDDEV(new_stack) FROM bestbet
GROUP BY game_only_id
ORDER BY game_only_id;


-- risked money, chance_of_winning / game
SELECT (SUBSTRING(game_id, 6))::INTEGER as game_only_id, AVG(risked_money) as avg_risked_money, AVG(chance_of_winning) as avg_chance_of_winning
FROM bestbet
GROUP BY game_only_id
ORDER BY game_only_id;

-- risked money, chance_of_winning / day
SELECT my_date, AVG(risked_money) as avg_risked_money, AVG(chance_of_winning) as avg_chance_of_winning
FROM bestbet
GROUP BY my_date
ORDER BY my_date;

-- number of games with 0 new_stack (all, not only after round 50) 
SELECT COUNT(zeros) FROM 
(SELECT game_id, COUNT(*) as zeros FROM bestbet 
WHERE new_stack = 0
GROUP BY game_id) as zero_stack;

-- games with zero stacks before round 50 AND not played to the end (= round 50)
SELECT COUNT(*) as one_zeros_before_round_50 FROM
(SELECT game_id, COUNT(*) as zeros_before_round_50 FROM
(SELECT * FROM bestbet
WHERE new_stack = 0 AND round_id != 50) as zeros
GROUP BY game_id
HAVING COUNT(*) = 1) as one_zeros;




