// Import and register all your controllers from the importmap under controllers/*

import { application } from 'controllers/application'

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from '@hotwired/stimulus-loading'
import Notification from '@stimulus-components/notification'

// Register the Notification component
application.register('notification', Notification)
eagerLoadControllersFrom('controllers', application)
