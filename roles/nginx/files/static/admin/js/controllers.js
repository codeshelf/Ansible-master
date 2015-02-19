/**
 * MainCtrl - controller
 */
function MainCtrl($scope, $http) {

    this.userName = 'Example user';
    this.helloText = 'Welcome in SeedProject';
    this.descriptionText = 'It is an application skeleton for a typical AngularJS web app. You can use it to quickly bootstrap your angular webapp projects and dev environment for these projects.';

    $http.get('/resources/hosts.json').
    success(function(data) {
    	$scope.servers = data;
    	// extract server hosts
    	for (i = 0; i < $scope.servers.length; ++i) {
    		// fetch health check data for app servers
    		var server = $scope.servers[i];
    		// server.healthchecks = [];
    		// fetch health check status from app servers
    		if (server.roles.indexOf('appserver')>=0 || server.roles.indexOf('sitecontroller')>=0) {
    			var hostName = server.host;
    		    $http.get('https://admin.codeshelf.com/'+hostName+'/adm/healthchecks').
    		    error((function(server) {
    		        return function(data, status, headers, config) {
    		        	if (status==500) {
            		    	server.healthchecks = [];
            		    	if (Array.isArray(data)) {
            		    		// not implemented yet
            		    		/*
        	    		    	for (i = 0; i < data.length; ++i) {
        	    		    		server.healthchecks.push(data);
        	    		    	}
        	    		    	*/
        	    		    }
            		    	else {
            		    		for (var hcName in data)  {
            						var status = 'n/a';
            						if (data[hcName].healthy==true) {
            							status = "ok";
            						}
        							else {
            							status = "fail";								
        							}
                		    		server.healthchecks.push(createHealthCheck(prettyString(hcName), status, data[hcName].message)); 
            		    		}
            		    	};    		        
            		    }
    		        	else {
    		        		debugger;
	    		        	server.error = "Failed to connect to server to run health checks.";
	    		        	$scope.$digest();
    		        	}
    		        }
    		    })(server)).   		    
    		    success((function(server) {
    		        return function(data) {
        		    	server.healthchecks = [];
        		    	if (Array.isArray(data)) {
        		    		// not implemented yet
        		    		/*
    	    		    	for (i = 0; i < data.length; ++i) {
    	    		    		server.healthchecks.push(data);
    	    		    	}
    	    		    	*/
    	    		    }
        		    	else {
        		    		for (var hcName in data)  {
        						var status = 'n/a';
        						if (data[hcName].healthy==true) {
        							status = "ok";
        						}
    							else {
        							status = "error";								
    							}
            		    		server.healthchecks.push(createHealthCheck(prettyString(hcName), status, data[hcName].message)); 
        		    		}
        		    	};    		        
        		    }
    		    })(server));
    		}
    		// fetch status from elasticsearch
    		if (server.roles.indexOf('elasticsearch')>=0) {
    			var hostName = server.host;
    		    $http.get('https://admin.codeshelf.com/'+hostName+'/_cluster/health').
    		    success((function(server) {
    		        return function(data) {
        		    	server.healthchecks = [];
        		    	if (data.status=='green') {
        		    		server.healthchecks.push(createHealthCheck("Elasticsearch Status", "ok", "Elasticsearch is healthy")); 
        		    	}
        		    	else {
        		    		server.healthchecks.push(createHealthCheck("Elasticsearch Status", "error", data.status));         		    		
        		    	}
    		        };
    		    })(server));
    		}
    	}
        // $scope.hosts = data;
    });
};

function prettyString(str) {
	str = str.replace('-', ' ');
    return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
}

function createHealthCheck(name, status, message) {
	var hc = {
			'name' : name,
			'status' : status,
			'message' : message
	}
	return hc;
}


angular
    .module('inspinia')
    .controller('MainCtrl ', MainCtrl)
