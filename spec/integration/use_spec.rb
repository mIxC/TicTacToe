require 'spec_helper'

describe 'home page' do
  it 'welcomes the user' do
    visit '/'
    page.should have_content('Welcome')
  end

  it 'make two users, create a game, and make a move', :js => true do
    visit '/'
    click_link('Create user')
    fill_in('user_name', :with => 'SomeGuy1')
    fill_in('user_password', :with => 'secretPass')
    fill_in('user_password_confirmation', :with => 'secretPass')
    click_button('sign up!')
    page.should have_content('SomeGuy1')

    find_link('Account').click
    click_link('Sign out')
    click_link('Create user')
    fill_in('user_name', :with => 'SomeGuy2')
    fill_in('user_password', :with => 'secretPass')
    fill_in('user_password_confirmation', :with => 'secretPass')
    click_button('sign up!')
    page.should have_content('SomeGuy2')

    click_link('Create game')
    fill_in('name', :with => 'Best Game Evar')
    choose('opponent_user')
    fill_in('user2_name', :with => 'SomeGuy1')
    click_button('make the game')
    page.should have_content('move here')

    find_link('move here').click
    page.should have_content('x')
  end

end

