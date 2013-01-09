require 'rubygems'
require 'rest-client'
require 'json'
require 'yaml'
require "base64"

class HomeController < ApplicationController
  def index





    @mode = params[:mode]
    @code = params[:code]

    @show_plus = @mode != 'gradingview'

    res = get_access_token(APP_CONFIG, @code)


    if res[:error] == true
      @error = res
      render "home/error"
      return
    end

    @acs_token = res[:res]

    @announcement_app_id = params[:announcementapplicationid].to_i

    user_res = get_current_user(@acs_token['access_token'])

    if user_res[:error] == true
      @error = user_res
      render "home/error"
      return
    end



    @current_user = user_res[:res]

    @current_user_id = @current_user['id'].to_i


    puts "is_teacher", @current_user[:is_teacher]

    #view teacher's question
    if @mode == 'view'
      if @current_user[:is_teacher]
        @question = Question.where('announcement_app_id = ? and schoolperson_id = ?', @announcement_app_id , @current_user_id).first
        return
      else
        @question = Question.where('announcement_app_id = ?', @announcement_app_id).first
        @answer = Answer.where('announcement_app_id = ? and schoolperson_id = ?', @announcement_app_id , @current_user_id).first_or_create
        return
      end
    elsif @mode == 'edit'
      @question = Question.where('announcement_app_id = ? and schoolperson_id = ?', @announcement_app_id , @current_user_id).first_or_create
      return
    elsif @mode == 'gradingview'
      @student_id = params[:studentid]
      @question = Question.where('announcement_app_id = ? and schoolperson_id = ?', @announcement_app_id, @current_user_id).first
      @answer = Answer.where('announcement_app_id = ? and schoolperson_id = ?', @announcement_app_id, @student_id).first
      return
    end

  end

  def post_question
    @edit_mode = params[:edit_mode]
    @announcement_app_id = params[:announcement_app_id].to_i
    @schoolperson_id = params[:schoolperson_id].to_i

    @question = Question.where('announcement_app_id = ? and schoolperson_id = ?', @announcement_app_id , @schoolperson_id).first_or_create

    @question.content = params[:question][:content]
    @question.announcement_app_id = @announcement_app_id
    @question.schoolperson_id = @schoolperson_id

    respond_to do |format|
      if @question.save
        format.json  { render :json => @question }
      end
    end
  end


  def post_answer
    @edit_mode = params[:edit_mode]
    @announcement_app_id = params[:announcement_app_id].to_i
    @schoolperson_id = params[:schoolperson_id].to_i

    @answer = Answer.where('announcement_app_id = ? and schoolperson_id = ?', @announcement_app_id, @schoolperson_id).first_or_create
    @answer.announcement_app_id = @announcement_app_id
    @answer.schoolperson_id = @schoolperson_id
    @answer.content = params[:answer][:content]

    respond_to do |format|
      if @answer.save
        format.json  { render :json => @answer }
      end
    end
  end

  private
  def get_access_token(settings, code)
    unless session[:acs_token].nil?
      if session[:acs_token][:code] == code
        return :res => JSON.parse(session[:acs_token][:token]), :error => false
      end
    end

    begin
      @response = RestClient.post(
          settings['acs_url'],
          'client_id' => settings['client_id'],
          'client_secret' => settings['client_secret'],
          'scope' => settings['scope'],
          'redirect_uri' => settings['redirect_uri'],
          'grant_type' => 'authorization_code',
          'code' => code
      )
    rescue => e
      return :res => e, :error => true, :stack_trace => e.backtrace
    end
    session[:acs_token] = {:token => @response, :code => code}
    return :res => JSON.parse(@response), :error => false
    #return :res => "", :error => false
  end

  def get_current_user(access_token)
    begin
      @response = RestClient.get(APP_CONFIG['service_url'], :authorization => "Bearer:" + access_token)
      res = JSON.parse(@response)['data']
      res[:is_teacher] = res['rolename'] == 'Teacher'
      return :res => res, :error => false
    rescue => e
      return :res => e, :error => true, :stack_trace => e.backtrace
    end
    #return :res => {:id => 123, :rolename => 'Teacher', :is_teacher => true ,:displayname => "Ms. Rachel Harari"}, :error => false
  end


end
