// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require jquery-ui
//= require private_pub
//= require jquery_nested_form
//= require_tree .

$(function(){
  // apply the placeholder shim for the rich and prosperous elements.
  $('.placeholder-shim').placeholder();
  // $('#user_identifier').autocomplete({source: "/users.json"});
  $('select.user_identifier').selectize({
    valueField: 'andrewid',
    labelField: 'name',
    searchField: ['name', 'andrewid'],
    create: false,
    render: {
      option: function(item, escape) {
        return '<div>' + escape(item.name) + ' &#60;' + escape(item.andrewid) + '&#62; </div>';
      }
    },
    load: function(query, callback) {
      if(!query.length) return callback();
      $.ajax({
        url: '/users.json?term=' + encodeURIComponent(query),
        type: 'GET',
        error: function() {
          callback();
        },
        success: function(res) {
          callback(res);
        }
      });
    }
  });

  $('select.user_identifiers').selectize({
    valueField: 'andrewid',
    labelField: 'name',
    searchField: ['name', 'andrewid'],
    create: false,
    render: {
      option: function(item, escape) {
        return '<div>' + escape(item.name) + ' &#60;' + escape(item.andrewid) + '&#62; </div>';
      }
    },
    load: function(query, callback) {
      if(!query.length) return callback();
      $.ajax({
        url: '/users.json?term=' + encodeURIComponent(query),
        type: 'GET',
        error: function() {
          callback();
        },
        success: function(res) {
          callback(res);
        }
      });
    }
  });

  $('.nav-search').selectize({
    valueField: 'link',
    labelField: 'name',
    searchField: ['name'],
    autogrow: false,
    maxItems: 1,
    render: {
      option: function(item, escape) {
        return '<div><img src="'+escape(item.thumbnail)+'"><span class="name">' + escape(item.name) + '</span>'+
        '<span class="description">'+escape(item.type)+'</span></div>';
      }
    },
    load: function(query, callback) {
      if(!query.length) return callback();
      $.ajax({
        url: '/dashboard/search.json?q=' + encodeURIComponent(query),
        type: 'GET',
        error: function() {
          callback();
        },
        success: function(res) {
          callback(res.results);
        }
      });
    },
    onItemAdd: function(value, item) {
      window.location.replace(value);
    }
  });

  $('select.recipients_field').selectize({
    valueField: 'value',
    labelField: 'name',
    searchField: ['name'],
    create: false,
    maxItems: null,
    render: {
      option: function(item, escape) {
        return '<div>' + escape(item.name) + '</div>';
      }
    },
    load: function(query, callback) {
      if(!query.length) return callback();
      $.ajax({
        url: '/messages/recipient_search.json?query=' + encodeURIComponent(query),
        type: 'GET',
        error: function() {
          callback();
        },
        success: function(res) {
          callback(res);
        }
      });
    }
  });
});
