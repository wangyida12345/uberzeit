require 'spec_helper'

describe CalculatePlannedWorkingTime do

  let(:calculator) { CalculatePlannedWorkingTime.new(date_or_range, user) }
  let(:calculator_enforce_fulltime) { CalculatePlannedWorkingTime.new(date_or_range, user, fulltime: true) }
  let(:user) { FactoryGirl.create(:user, with_employment: false) }

  describe 'with a date' do
    let(:date_or_range) { '2013-03-06'.to_date }

    it 'returns the planned work for a full time employment' do
      FactoryGirl.create(:employment, workload: 100, user: user)
      calculator.total.should eq(8.5.hours)
    end

    it 'returns the planned work for a part time employment' do
      FactoryGirl.create(:employment, workload: 50, user: user)
      calculator.total.should eq((8.5/2).hours)
    end

    it 'returns zero if the user did not have an employment' do
      FactoryGirl.create(:employment, start_date: '2014-01-01'.to_date, user: user)
      calculator.total.should eq(0)
    end

    context 'when enforcing all employments to be full time employments' do
      it 'returns the planned work (but treats the part time employment as a full time employment)' do
        FactoryGirl.create(:employment, workload: 50, user: user)
        calculator_enforce_fulltime.total.should eq(8.5.hours)
      end
    end
  end

  shared_examples_for 'range' do
    it 'returns the planned work for a full time employment' do
      FactoryGirl.create(:employment, workload: 100, user: user)
      calculator.total.should eq(5*8.5.hours)
    end

    it 'returns the planned work for a part time employment' do
      FactoryGirl.create(:employment, workload: 50, user: user)
      calculator.total.should eq((5*8.5/2).hours)
    end

    it 'returns zero if the user did not have an employment' do
      FactoryGirl.create(:employment, start_date: '2014-01-01'.to_date, user: user)
      calculator.total.should eq(0)
    end

    context 'when enforcing all employments to be full time employments' do
      it 'returns the planned work (but treats the part time employment as a full time employment)' do
        FactoryGirl.create(:employment, workload: 50, user: user)
        calculator_enforce_fulltime.total.should eq(5*8.5.hours)
      end
    end
  end

  describe 'exclusive range' do
    let(:date_or_range) { '2013-03-04'.to_date...'2013-03-09'.to_date }
    it_behaves_like 'range'
  end

  describe 'inclusive range' do
    let(:date_or_range) { '2013-03-04'.to_date..'2013-03-09'.to_date }
    it_behaves_like 'range'
  end


  describe 'special case: employment starts in the middle of the month' do
    let(:date_or_range) { '2013-01-01'.to_date..'2013-01-31'.to_date }

    it 'returns the planned work for part time employment which starts in the middle of the month' do
      FactoryGirl.create(:employment, start_date: '2013-01-21'.to_date, workload: 100, user: user)
      calculator.total.should eq(76.5.hours)
    end
  end

  describe '#total_per_date' do
    let(:date_or_range) { '2013-03-03'.to_date..'2013-03-04'.to_date }

    it 'returns the calculated planned work time per day' do
      FactoryGirl.create(:employment, workload: 100, user: user)
      calculator.total_per_date.should eq({
        Date.civil(2013, 3, 3) => 0,
        Date.civil(2013, 3, 4) => 1.work_days,
      })
    end
  end
end
