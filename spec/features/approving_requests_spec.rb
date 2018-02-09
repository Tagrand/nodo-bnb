feature 'approve single booking' do
  before do
    DatabaseCleaner.clean_with(:truncation)
    signup
    login
    fill_in_listing
    click_button 'List my space'
    click_button 'Logout'
    signup(username: 'bob', password: 'Bobrules')
    click_button 'Book'
    click_button 'Logout'
    login
    click_link 'Booking Requests'
  end

  scenario 'a lister can see a booking request has been made' do
    expect(page).to have_content 'My house'
  end

  scenario 'a lister can approve a booking' do
    click_button 'Approve'
    expect(Space.first.booking).to eq('booked')
    expect(page).to have_content 'Booking approved'
    expect(page).not_to have_content 'My house'
  end

end

feature 'filters out unrequested bookings' do
  before do
    DatabaseCleaner.clean_with(:truncation)
    signup
    fill_in_listing
    click_button 'List my space'
    fill_in_listing(name: 'Anything',
                    description: 'The best place!',
                    price: '10',
                    from_date: '16/03/2018',
                    to_date: '16/04/2018')
    click_button 'List my space'
    click_button 'Logout'
    signup(username: 'John' , password: 'password')
  end

  scenario 'approving a booking' do
    click_button('space2')
    click_button 'Logout'
    login
    click_link 'Booking Requests'
    click_button 'Approve'
    expect(Space.get(2).booking).to eq('booked')
    expect(Space.get(1).booking).to eq 'available'
    expect(page).to have_content 'Booking approved'
    expect(page).not_to have_content 'My house'
    expect(page).not_to have_content 'Anything'
  end

  scenario 'another user signs in' do
   fill_in_listing(name: 'Makers Academy',
                   description: 'We love a good diagram!',
                   price: '8000',
                   from_date: '02/01/2018',
                   to_date: '16/03/2018')
    click_button 'List my space'
    click_button('space2')
    click_button 'Logout'
    signup(username: 'EdW', password: 'Confused')
    click_button('space3')
    click_button 'Logout'
    login
    click_link 'Booking Requests'
    expect(page).not_to have_content 'Makers'
    expect(page).to have_content 'Anything'
  end
end

feature 'Only displaying unapproved spaces for booking' do
  scenario 'After a place is book and approved it should disappear' do
    signup
    fill_in_listing
    click_button 'List my space'
    fill_in_listing(name: 'Makers Academy',
                    description: 'We love a good diagram!',
                    price: '8000',
                    from_date: '02/01/2018',
                    to_date: '16/03/2018')
    click_button 'List my space'
    click_button 'Logout'
    signup(username: 'dom', password: 'tom')
    click_button('space2')
    click_button 'Logout'
    login
    click_link 'Booking Requests'
    click_button 'Approve'
    click_link 'View spaces'
    expect(page).to have_content 'My house'
    expect(page).not_to have_content 'Makers Academy'
  end
end
