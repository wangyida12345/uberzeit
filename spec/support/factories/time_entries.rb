FactoryGirl.define do
  factory :time_entry do
    ignore do
      duration UberZeit::Config[:work_per_day]
      time_type :work
    end

    user
    start_date { Date.current }
    start_time { '8:00' }
    end_date { Date.current }
    end_time   { '12:00' }

    after(:build) do |entry, evaluator|
      entry.time_type = TEST_TIME_TYPES[evaluator.time_type]
    end

    factory :invalid_time_entry do
      end_time { start_time }
    end

    factory :timer do
      end_date nil
      end_time nil
    end
  end
end