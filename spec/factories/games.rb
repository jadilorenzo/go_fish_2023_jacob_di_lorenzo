FactoryBot.define do
  factory :game do
    trait :started do
      started_at { Time.zone.now }
    end

    trait :finished do
      started_at { 5.minutes.ago }
      finished_at { Time.zone.now }
    end
  end
end
