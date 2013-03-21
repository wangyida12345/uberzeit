require 'spec_helper'

describe TimeSheet do

  let(:time_sheet) { FactoryGirl.create(:time_sheet) }

  def add_entry(start_time, end_time, type = :work, daypart = nil)
    if daypart
      FactoryGirl.create(:absence, start_date: start_time.to_date, end_date: end_time.to_date, time_type: type, time_sheet: time_sheet, daypart: daypart)
    else
      FactoryGirl.create(:time_entry, start_time: start_time.to_time, end_time: end_time.to_time, time_type: type, time_sheet: time_sheet)
    end
  end

  context 'time-sheet with a complex weekly schedule (time entries)' do
    before do
      @stats = {}

      # sunday previous week (night shift)
      add_entry('2013-02-03 18:00:00 GMT+1', '2013-02-04 00:00:00 GMT+1')

      # monday
      add_entry('2013-02-04 09:00:00 GMT+1', '2013-02-04 12:00:00 GMT+1')
      add_entry('2013-02-04 12:00:00 GMT+1', '2013-02-04 12:30:00 GMT+1', :break)
      add_entry('2013-02-04 12:30:00 GMT+1', '2013-02-04 18:00:00 GMT+1')
      # @stats['2013-02-04'] = { num_work_entries: 2, work: 8.5.hours, overtime: 0, vacation: 0 }

      # tuesday, one day closer to the weekend
      add_entry('2013-02-05 09:00:00 GMT+1', '2013-02-05 12:00:00 GMT+1')
      add_entry('2013-02-05 12:00:00 GMT+1', '2013-02-05 12:30:00 GMT+1', :break)
      add_entry('2013-02-05 12:30:00 GMT+1', '2013-02-05 16:30:00 GMT+1')
      # @stats['2013-02-05'] = { num_work_entries: 2, work: 7.hours, overtime: 0, vacation: 0 }

      # wednesday we take a day off
      add_entry('2013-02-06 00:00:00 GMT+1', '2013-02-06 00:00:00 GMT+1', :vacation, :whole_day)
      # @stats['2013-02-06'] = { num_work_entries: 0, work: 0, overtime: 0, vacation: 1.work_days }

      # thursday we decide to work through the night
      add_entry('2013-02-07 16:00:00 GMT+1', '2013-02-07 18:00:00 GMT+1')
      add_entry('2013-02-07 18:00:00 GMT+1', '2013-02-07 20:00:00 GMT+1', :break)
      add_entry('2013-02-07 20:00:00 GMT+1', '2013-02-08 03:00:00 GMT+1')
      # @stats['2013-02-07'] = { num_work_entries: 2, work: 6.hours, overtime: 0, vacation: 0 }

      # thank god it's friday
      add_entry('2013-02-08 12:00:00 GMT+1', '2013-02-08 19:00:00 GMT+1')
      # @stats['2013-02-08'] = { num_work_entries: 1, work: 10.hours, overtime: 1.5.hours, vacation: 0 }

      # saturday off

      # sunday we decide to work, just for fun
      add_entry('2013-02-10 22:00:00 GMT+1', '2013-02-11 00:00:00 GMT+1')
      # @stats['2013-02-10'] = { num_work_entries: 1, work: 2.hours, overtime: 0, vacation: 0 }

      # monday next week begins early
      add_entry('2013-02-11 00:00:00 GMT+1', '2013-02-11 06:00:00 GMT+1')

      # tue-wed next week free
      add_entry('2013-02-12 00:00:00 GMT+1', '2013-02-13 00:00:00 GMT+1', :vacation, :whole_day)
    end

    it 'has a valid factory' do
      time_sheet.should be_valid
    end

    it 'acts as paranoid' do
      time_sheet.destroy
      expect { TimeSheet.find(time_sheet.id) }.to raise_error
      expect { TimeSheet.with_deleted.find(time_sheet.id) }.to_not raise_error
    end

    context 'user with full-time workload' do
      it 'delivers single entries which are cut to the specified date or range (chunks)' do
        time_sheet.find_chunks('2013-02-04'.to_date...'2013-02-11'.to_date, :work).length.should eq(8)

        # we work edthrough the night on 02-07 so we expect two chunks for 02-08
        time_sheet.find_chunks('2013-02-08'.to_date, :work).length.should eq(2)

        # check sunday for borderline
        time_sheet.find_chunks('2013-02-10'.to_date, :work).length.should eq(1)

        # what about times and timezones?
        time_sheet.find_chunks('2013-02-04 00:00:00 GMT+1'.to_time..'2013-02-04 09:00:00 GMT+1'.to_time).should be_empty
        time_sheet.find_chunks('2013-02-04 00:00:00 GMT+1'.to_time..'2013-02-04 09:05:00 GMT+1'.to_time).should_not be_empty
      end

      it 'calculates the total duration (daily and weekly)' do
        time_sheet.total('2013-02-04'.to_date...'2013-02-11'.to_date, :work).should eq(33.5.hours)
        time_sheet.total('2013-02-04'.to_date...'2013-02-11'.to_date, :vacation).should eq(1.work_days)

        # what about times and timezones?
        time_sheet.total('2013-02-04 10:00:00 GMT+1'.to_time..'2013-02-10 22:00:00 GMT+1'.to_time, :work).should eq(30.5.hours)
      end

      it 'calculates the weekly overtime duration' do
        time_sheet.overtime('2013-02-04'.to_date...'2013-02-11'.to_date).should eq(-0.5.hours)
      end

      it 'calculates the daily overtime duration' do
        time_sheet.overtime('2013-02-08'.to_date).should eq(1.5.hours)
      end

      it 'calculates the number of redeemed vacation days for the year' do
        time_sheet.vacation(2013).should eq(3.0.work_days)
      end

      it 'calculates the number of remaining vacation days for the year' do
        time_sheet.remaining_vacation(2013).should eq(22.0.work_days)
      end

    end

    context 'user with part-time workload' do
      # TODO comment why we expect what
      before do
        employment = time_sheet.user.employments.first
        employment.workload = 50
        employment.save

        time_sheet.reload
      end

      it 'calculates the weekly overtime duration' do
        time_sheet.overtime('2013-02-04'.to_date...'2013-02-11'.to_date).should eq(20.75.hours)
      end

      it 'calculates the number of redeemed vacation days for the year' do
        time_sheet.vacation(2013).should eq(3.0.work_days)
      end

      it 'calculates the number of remaining vacation days for the year' do
        time_sheet.remaining_vacation(2013).should eq(9.5.work_days)
      end
    end
  end

  context 'time-sheet with both one time and recurring entries plus holidays' do
    before do
      # recurring entry every monday paid absence for 4 weeks
      absence_entry = add_entry('2013-03-04', '2013-03-04', :paid_absence, :whole_day)
      absence_entry.recurring_schedule.update_attributes(active: true, ends: 'counter', ends_counter: 4, weekly_repeat_interval: 1)

      # tuesday vacation
      add_entry('2013-03-19', '2013-03-19', :vacation, :whole_day)
      # wednesday morning off
      add_entry('2013-03-20', '2013-03-20', :vacation, :first_half_day)
      add_entry('2013-03-20 13:00:00 GMT+1', '2013-03-20 17:15:00 GMT+1', :work)
      # thursday is a normal work day
      add_entry('2013-03-21 08:00:00 GMT+1', '2013-03-21 12:00:00 GMT+1', :work)
      add_entry('2013-03-21 12:30:00 GMT+1', '2013-03-21 17:00:00 GMT+1', :work)
      # and friday is a public holiday, what a lovely week!
      # (public holidays are not counted as work days)
      FactoryGirl.create(:public_holiday, start_date: '2013-03-22', end_date: '2013-03-22')
    end

    it 'calculates the work time' do
      time_sheet.work('2013-03-18'.to_date...'2013-03-25'.to_date).should eq(34.hours)
    end

    it 'calculates the overtime' do
      time_sheet.overtime('2013-03-18'.to_date...'2013-03-25'.to_date).should eq(0)
    end
  end

  # context 'time-sheet with both single-entries and recurring-entries' do
  #   before do
  #     time_sheet = FactoryGirl.create(:time_sheet)

  #     # Monday we work in the afternoon
  #     add_entry('2013-03-04 13:00:00 GMT+1', '2013-03-04 18:00:00 GMT+1')

  #     # We take the morning off for this week
  #     add_recurring_entry({ start_time: '2013-03-04 07:45:00 GMT+1',
  #                           end_time: '2013-03-04 12:00:00 GMT+1',
  #                           repeat_unit: 'daily',
  #                           ends: 'date',
  #                           ends_date: '2013-03-08'}, :vacation)
  #   end

  #   it 'calculates the number of redeemed vacation days for the year' do
  #     time_sheet.vacation(2013).should eq(2.5.work_days)
  #   end

  #   it 'calculates the weekly work duration' do
  #     time_sheet.total('2013-03-04'.to_date..'2013-03-11'.to_date, :work).should eq(5.hours)
  #   end
  # end

end
