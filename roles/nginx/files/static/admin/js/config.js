/**
 * INSPINIA - Responsive Admin Theme
 * Copyright 2014 Webapplayers.com
 *
 * Inspinia theme use AngularUI Router to manage routing and views
 * Each view are defined as state.
 * Initial there are written stat for all view in theme.
 *
 */
function config($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise("/main");
    $stateProvider
        .state('main', {
            url: "/main",
            templateUrl: "views/main.html",
            data: { pageTitle: 'Hosts' }
        })
        .state('sitecontrollers', {
            url: "/sitecontrollers",
            templateUrl: "views/sitecontrollers.html",
            data: { pageTitle: 'Site Controllers' }
        })
        .state('productivity', {
            url: "/productivity",
            templateUrl: "views/productivity.html",
            data: { pageTitle: 'Productivity' }
        });

}
angular
    .module('inspinia')
    .config(config)
    .run(function($rootScope, $state) {
        $rootScope.$state = $state;
    });
