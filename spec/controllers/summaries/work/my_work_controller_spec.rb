require 'spec_helper'

describe Summaries::Work::MyWorkController do
  render_views

  let(:user) { FactoryGirl.create(:user, with_sheet: true) }
  let(:year) { 2013 }
  let(:month) { 3 }

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :year, user_id: user, year: year
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed-in users' do

    before do
      test_sign_in user
    end

    describe 'GET "year"' do
      it 'assigns the correct instance variables' do
        get :year, user_id: user, year: year
        assigns(:year).should_not be_nil
        assigns(:table).should_not be_nil
      end

      it 'renders the :year template' do
        get :year, user_id: user, year: year
        response.should render_template :year
      end
    end

    describe 'GET "month"' do
      it 'assigns the correct instance variables' do
        get :month, user_id: user, year: year, month: month
        assigns(:year).should_not be_nil
        assigns(:month).should_not be_nil
        assigns(:table).should_not be_nil
      end

      it 'renders the :month template' do
        get :month, user_id: user, year: year, month: month
        response.should render_template :month
      end
    end

  end

end