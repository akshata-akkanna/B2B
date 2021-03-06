import './buyer_accounts.html';

import { Meteor } from 'meteor/meteor';
import { Session } from 'meteor/session'

var balance = new ReactiveArray(); 

Template["components_buyer_acounts"].onCreated(function(){
	var template = this;
});

Template['components_buyer_acounts'].onRendered(function(){
	var template = this;
	var data ={address: Session.get("BuyerUserAddress")};
	TemplateVar.set(template,'accountInfo', {});

	Meteor.call('getBalance',data,function(error,result){
	if (error) {
		console.log("Error occured while fetching Client Work Order results");
	}
	else {
			TemplateVar.set(template,'accountInfo', 
			{account_number: result.account_number, balance : result.balance,});
	}
	});
})

