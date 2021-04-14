// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require accessible-autocomplete/dist/accessible-autocomplete.min.js
//= require rails-ujs
//= require govuk-frontend/govuk/all
//= require_tree .

/*
document.addEventListener("DOMContentLoaded", function() {
  var budgetTypeRadios = document.querySelectorAll('input[name="budget[budget_type]"].govuk-radios__input');

  var transferredBudgets = [3];
  var externalBudgets = [4, 5];

  budgetTypeRadios.forEach((elem) => {
    elem.addEventListener("change", function(event) {
      var item = event.target.value;
      console.log(item);

      if(item == 3) {
        // show providing org select
        document.querySelector("#providing-org-select");
      }

      if(item == 4 || item == 5) {
        // show providing org freeform fields
      }
    });
  })
})
*/
