//
//  HabitDetailsViewController.swift
//  Active
//
//  Created by Tiago Maia Lopes on 02/07/18.
//  Copyright © 2018 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData
import JTAppleCalendar
import UserNotifications

class HabitDetailsViewController: UIViewController {

    // MARK: Properties

    /// The habit presented by this controller.
    var habit: HabitMO! {
        didSet {
            habitColor = habit.getColor().uiColor
        }
    }

    /// The current habit's color.
    private(set) var habitColor: UIColor!

    /// The habit's ordered challenge entities to be displayed.
    /// - Note: This array mustn't be empty. The existence of challenges is ensured
    ///         in the habit's creation and edition process.
    private var challenges: [DaysChallengeMO]! {
        didSet {
            // Store the initial and final calendar dates.
            startDate = challenges.first!.fromDate!.getBeginningOfMonth()!
            finalDate = challenges.last!.toDate!
        }
    }

    /// The initial calendar date.
    internal var startDate: Date!

    /// The final calendar date.
    internal var finalDate: Date!

    /// The habit storage used to manage the controller's habit.
    var habitStorage: HabitStorage!

    /// The persistent container used by this store to manage the
    /// provided habit.
    var container: NSPersistentContainer!

    /// The edit segue identifier taking to the HabitCreationViewController.
    private let editSegueIdentifier = "Edit the habit"

    /// The identifier of the "new challenge" segue taking to the HabitDaysSelectionViewController.
    private let newChallengeSegueIdentifier = "Add new challenge to the habit"

    /// The identifier of the segue taking to the FireTimesSelectionController.
    private let newFireTimesSegueIdentifier = "Add fire times to habit"

    /// The cell's reusable identifier.
    internal let cellIdentifier = "Habit day cell id"

    /// The calendar view showing the habit days.
    /// - Note: The collection view will show a range with
    ///         the Habit's first days until the last ones.
    @IBOutlet weak var calendarView: JTAppleCalendarView!

    /// The month header view, with the month label and next/prev buttons.
    @IBOutlet weak var monthHeaderView: MonthHeaderView! {
        didSet {
            monthTitleLabel = monthHeaderView.monthLabel
            nextMonthButton = monthHeaderView.nextButton
            previousMonthButton = monthHeaderView.previousButton
        }
    }

    /// The month title label in the calendar's header.
    internal weak var monthTitleLabel: UILabel!

    /// The next month header button.
    internal weak var nextMonthButton: UIButton! {
        didSet {
            nextMonthButton.addTarget(self, action: #selector(goNext), for: .touchUpInside)
        }
    }

    /// The previous month header button.
    internal weak var previousMonthButton: UIButton! {
        didSet {
            previousMonthButton.addTarget(self, action: #selector(goPrevious), for: .touchUpInside)
        }
    }

    /// The view holding the prompt for the current day.
    /// - Note: This view is only displayed if today is a challenge day to be accounted.
    @IBOutlet weak var promptContentView: UIView!

    /// The title displaying what challenge's day is today.
    @IBOutlet weak var currentDayTitleLabel: UILabel!

    /// The switch the user uses to mark the current habit's day as executed.
    @IBOutlet weak var wasExecutedSwitch: UISwitch!

    /// The supporting label informing the user that the activity was executed.
    @IBOutlet weak var promptAnswerLabel: UILabel!

    /// The view holding the habit's current active challenge's progress section.
    /// - Note: This view is only displayed if there's an active challenge for the habit.
    @IBOutlet weak var challengeProgressContentView: UIView!

    /// The label displaying how many days to finish the current days' challenge.
    @IBOutlet weak var daysToFinishLabel: UILabel!

    /// The label displaying how many days were executed in the current days' challenge.
    @IBOutlet weak var executedDaysLabel: UILabel!

    /// The label displaying how many days were missed in the current days' challenge.
    @IBOutlet weak var missedDaysLabel: UILabel!

    /// The bar view displaying the current challenge's progress.
    @IBOutlet weak var progressBar: ProgressView!

    /// The view holding the "No active challenge" section.
    @IBOutlet weak var noChallengeContentView: UIView!

    /// The new challenge button displayed for the habits that don't have an active days'
    /// challenge at the moment.
    @IBOutlet weak var newChallengeButton: RoundedButton!

    /// The notification manager used to get the authorization status.
    var notificationManager: UserNotificationManager!

    /// The view containing the fire time labels.
    @IBOutlet weak var fireTimesContentView: UIView!

    /// The label displaying the number of selected fire times.
    @IBOutlet weak var fireTimesAmountLabel: UILabel!

    /// The label displaying the habit's fire times.
    @IBOutlet weak var fireTimesLabel: UILabel!

    /// The view containing information for when there are no fire times set for the habit.
    @IBOutlet weak var noFireTimesContentView: UIView!

    /// The content view showing that notifications aren't authorized by the user.
    @IBOutlet weak var notificationsAuthContentView: UIView!

    /// The button that takes to the fire times controller.
    @IBOutlet weak var newFireTimesButton: RoundedButton!

    // MARK: Deinitializers

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: ViewController Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register to possible notifications thrown by changes in other managed contexts.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleContextChanges(notification:)),
            name: Notification.Name.NSManagedObjectContextDidSave,
            object: nil
        )

        // Refresh the user notifications authorization view every time the app become active.
        observeForegroundEvent()

        checkDependencies()
        // Get the habit's challenges to display in the calendar.
        challenges = getChallenges(from: habit)

        // Configure the calendar.
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self

        title = habit.name
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Show the current date in the calendar.
        let today = Date().getBeginningOfDay()
        calendarView.scrollToDate(today)

        // Display the initial state of the sections.
        displaySections()

        // Check the auth status and update the fire times section accordingly.
        getAuthStatus()
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case editSegueIdentifier:
            guard let editionController = segue.destination as? HabitCreationTableViewController else {
                assertionFailure("Error: Couldn't get the HabitCreationController.")
                return
            }
            editionController.container = container
            editionController.userStore = UserStorage()
            editionController.habitStore = habitStorage
            editionController.notificationManager = notificationManager
            editionController.habit = habit

        case newChallengeSegueIdentifier:
            guard let daysSelectionController = segue.destination as? HabitDaysSelectionViewController else {
                assertionFailure("Error: Couldn't get the HabitDaysSelectionController")
                return
            }
            daysSelectionController.themeColor = habitColor
            daysSelectionController.delegate = self

        case newFireTimesSegueIdentifier:
            guard let fireTimesSelectionController = segue.destination as? FireTimesSelectionViewController else {
                assertionFailure("Error: Couldn't get the FireTimesSelectionController")
                return
            }
            fireTimesSelectionController.delegate = self
            fireTimesSelectionController.themeColor = habitColor
            fireTimesSelectionController.notificationManager = UserNotificationManager(
                notificationCenter: UNUserNotificationCenter.current()
            )
            
        default:
            break
        }
    }

    // MARK: Actions

    /// Makes the calendar display the next month.
    @objc private func goNext() {
        goToNextMonth()
    }

    /// Makes the calendar display the previous month.
    @objc private func goPrevious() {
        goToPreviousMonth()
    }

    /// Listens to any saved changes happening in other contexts and refreshes
    /// the viewContext.
    /// - Parameter notification: The thrown notification
    @objc private func handleContextChanges(notification: Notification) {
        // If there's an update in the habit being displayed, update the controller's view.
        if (notification.userInfo?["updated"] as? Set<NSManagedObject>) != nil {
            DispatchQueue.main.async {
                // Update the title, if changed.
                if self.title != self.habit.name {
                    self.title = self.habit.name
                }

                // Update the habit's color.
                self.habitColor = self.habit.getColor().uiColor

                // Update the challenges.
                self.challenges = self.getChallenges(from: self.habit)

                // Update the calendar.
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                    self.calendarView.reloadData()
                    self.calendarView.scrollToDate(
                        Date().getBeginningOfDay() // Today
                    )
                }

                // Update the sections.
                self.displaySections()
            }
        }

        // Merge the changes from the habit's edition.
        container.viewContext.mergeChanges(fromContextDidSave: notification)
    }

    // MARK: Imperatives

    /// Asserts on the values of the main controller's dependencies.
    private func checkDependencies() {
        // Assert on the required properties to be injected
        // (habit, habitStorage, container and the calendar header views):
        assert(
            habit != nil,
            "Error: the needed habit wasn't injected."
        )
        assert(
            habitStorage != nil,
            "Error: the needed habitStorage wasn't injected."
        )
        assert(
            container != nil,
            "Error: the needed container wasn't injected."
        )
        assert(
            monthTitleLabel != nil,
            "Error: the month title label wasn't set."
        )
        assert(
            nextMonthButton != nil,
            "Error: the next month button wasn't set."
        )
        assert(
            previousMonthButton != nil,
            "Error: the previous month button wasn't set."
        )
        assert(
            notificationManager != nil,
            "Error: the notification manager wasn't injected."
        )
    }

    /// Updates and handles the display of each controller's section.
    private func displaySections() {
        // Configure the appearance of the prompt section.
        displayPromptView()

        // Configure the appearance of the challenge's progress section.
        displayProgressSection()

        // Display the no challenge view, if there's no active challenge for the habit.
        displayNoChallengesView()

        // Display the fire times section.
        displayFireTimesSection()
    }

    /// Gets the challenges from the passed habit ordered by the fromDate property.
    /// - Returns: The habit's ordered challenges.
    func getChallenges(from habit: HabitMO) -> [DaysChallengeMO] {
        // Declare and configure the fetch request.
        let request: NSFetchRequest<DaysChallengeMO> = DaysChallengeMO.fetchRequest()
        request.predicate = NSPredicate(format: "habit = %@", habit)
        request.sortDescriptors = [NSSortDescriptor(key: "fromDate", ascending: true)]

        // Fetch the results.
        let results = (try? container.viewContext.fetch(request)) ?? []

        // Assert on the values, the habit must have at least one challenge entity.
        assert(!results.isEmpty, "Inconsistency: A habit entity must always have at least one challenge entity.")

        return results
    }

    /// Gets the challenge matching a given date.
    /// - Note: The challenge is found if the date is in between or is it's begin or final.
    /// - Returns: The challenge entity, if any.
    func getChallenge(from date: Date) -> DaysChallengeMO? {
        // Try to get the matching challenge by filtering through the habit's fetched ones.
        // The challenge matches when the passed date or is in between,
        // or is one of the challenge's limit dates (begin or end).
        let filteredChallenges = challenges.filter {
            date.isInBetween($0.fromDate!, $0.toDate!) || date == $0.fromDate! || date == $0.toDate!
        }

        // If there's more than one challenge, filter by the ones that are open.
        if filteredChallenges.count > 1 {
            return filteredChallenges.filter { !$0.isClosed }.first
        } else {
            return filteredChallenges.last
        }
    }
}
