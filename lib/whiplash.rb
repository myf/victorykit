require 'distribution'
require 'redis'

class Float
  def to_1if0
    self.zero? ? 1 : self
  end
end

module Bandit
  def arm_guess(observations, victories)
    mean = victories.to_f/observations.to_f.to_1if0
    stddev = victories * (1-mean)**2
    stddev += ((observations - victories) * (0-mean))**2
    stddev = Math.sqrt(stddev * 1.0/((observations.to_f-1).to_1if0))
    stddev = (stddev||1)/Math.sqrt(observations.to_f.to_1if0)
    Distribution::Normal.rng(mean, stddev).call
  end

  def best_guess(options)
    guesses = {}
    options.each { |o, v| guesses[o] = arm_guess(v[0], v[1]) }
    best = options.keys.select { |o| guesses[o] == guesses.values.max }
    best.sample
  end

  def redis_nonce
    "#{session[:session_id]}_#{Random.rand}"
  end  

  def spin!(test_name, goal, options=[true, false])
    if session.key?(test_name) && options.include?(session[test_name])
      return session[test_name]
    end
    
    REDIS.sadd("test/goals/#{goal}", test_name)
    loptions = {}
    options.each { |o| loptions[o] = [
      REDIS.zcard("test/#{test_name}/#{o}/spin"),
      REDIS.zcard("test/#{test_name}/#{o}/win")
    ] }
    choice = best_guess(loptions)
    REDIS.zadd("test/#{test_name}/#{choice}/spin", Time.now.to_f, redis_nonce)
    session[test_name] = choice
    choice
  end

  def win!(goal)
    REDIS.smembers("test/goals/#{goal}").each do |t|
      REDIS.zadd("test/#{t}/#{session[t]}/win", Time.now.to_f, redis_nonce)
    end
  end
end