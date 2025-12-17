//
//  DataSeeder.swift
//  PollPal
//
//  Created by student on 03/12/25.
//  Updated for Prototype Showcase.
//

import CoreData
import Foundation

struct DataSeeder {

    static func seed(viewContext: NSManagedObjectContext) {
        // 1. Cek apakah database sudah ada isinya?
        if isDatabaseEmpty(viewContext: viewContext) {
            print("🌱 Database kosong. Memulai seeding data lengkap...")
            createData(viewContext: viewContext)
        } else {
            print("⚠️ Data sudah ada. Skip seeding.")
        }
    }

    private static func isDatabaseEmpty(viewContext: NSManagedObjectContext)
        -> Bool
    {
        let fetchRequest: NSFetchRequest<Survey> = Survey.fetchRequest()
        do {
            let count = try viewContext.count(for: fetchRequest)
            return count == 0
        } catch {
            return true
        }
    }

    private static func createData(viewContext: NSManagedObjectContext) {

        // --- HELPERS TANGGAL (Fix: Force Unwrap '!' agar tidak error optional) ---
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today)!
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: today)!

        // --- 1. CATEGORIES ---
        let catTech = createCategory(ctx: viewContext, name: "Technology")
        let catDaily = createCategory(ctx: viewContext, name: "Daily Life")
        let catHealth = createCategory(ctx: viewContext, name: "Health")
        let catGaming = createCategory(ctx: viewContext, name: "Gaming")
        let catFood = createCategory(ctx: viewContext, name: "Food & Beverage")

        // --- 2. USERS (4 PERSONA LENGKAP) ---

        // USER 1: FELICIA (Female, Surabaya, Gen Z)
        let felicia = User(context: viewContext)
        felicia.user_id = UUID()
        felicia.user_name = "Felicia Kathrin"
        felicia.user_email = "feli@gmail.com"
        felicia.user_pwd = "feli#123"
        felicia.user_point = 2000  // Cukup untuk redeem
        felicia.user_gender = "Female"
        felicia.user_birthplace = "Surabaya"
        felicia.user_birthdate = calendar.date(
            byAdding: .year,
            value: -20,
            to: today
        )
        felicia.user_hp = "081234567890"
        felicia.user_header_img = "mountain"
        felicia.user_profile_img = "cat"
        felicia.user_created_at = today
        felicia.user_status_del = false
        felicia.addToLike_category(catTech)
        felicia.addToLike_category(catDaily)

        print("🔑 USER ID FELICIA: \(felicia.user_id!.uuidString)")

        // USER 2: BUDI (Male, Jakarta, Millennial)
        let budi = User(context: viewContext)
        budi.user_id = UUID()
        budi.user_name = "Budi Santoso"
        budi.user_email = "budi@gmail.com"
        budi.user_pwd = "budi#123"
        budi.user_point = 5000  // Cukup untuk post banyak survey
        budi.user_gender = "Male"
        budi.user_birthplace = "Jakarta"
        budi.user_birthdate = calendar.date(
            byAdding: .year,
            value: -25,
            to: today
        )
        budi.user_hp = "081299998888"
        budi.user_header_img = "mountain"
        budi.user_profile_img = "cat"
        budi.user_created_at = today
        budi.user_status_del = false

        // USER 3: EVELIN (Ex-Siti) (Female, Bandung)
        let evelin = User(context: viewContext)
        evelin.user_id = UUID()
        evelin.user_name = "Evelin Alim"
        evelin.user_email = "evelin@gmail.com"
        evelin.user_pwd = "evelin#123"
        evelin.user_point = 1500  // Modal awal
        evelin.user_gender = "Female"
        evelin.user_birthplace = "Bandung"
        evelin.user_birthdate = calendar.date(
            byAdding: .year,
            value: -19,
            to: today
        )
        evelin.user_hp = "081877776666"
        evelin.user_header_img = "mountain"
        evelin.user_profile_img = "cat"
        evelin.user_created_at = today
        evelin.user_status_del = false

        // USER 4: ANDI (Male, Surabaya, Newbie)
        let andi = User(context: viewContext)
        andi.user_id = UUID()
        andi.user_name = "Andi Pratama"
        andi.user_email = "andi@gmail.com"
        andi.user_pwd = "andi#123"
        andi.user_point = 500  // Poin dikit (New User)
        andi.user_gender = "Male"
        andi.user_birthplace = "Surabaya"
        andi.user_birthdate = calendar.date(
            byAdding: .year,
            value: -22,
            to: today
        )
        andi.user_hp = "081355554444"
        andi.user_header_img = "mountain"
        andi.user_profile_img = "cat"
        andi.user_created_at = today
        andi.user_status_del = false

        // --- 3. SURVEYS (SCENARIOS) ---

        // SCENARIO 1: UNIVERSAL (Muncul di Felicia)
        let surveyAI = createSurvey(
            ctx: viewContext,
            owner: budi,
            title: "Penggunaan AI Mahasiswa",
            desc: "Seberapa sering mahasiswa menggunakan ChatGPT untuk tugas?",
            points: 50,
            quota: 100,
            deadline: nextWeek,
            gender: "All",
            loc: "All",
            minAge: 18,
            maxAge: 30,
            categories: [catTech],
            img: "survey_ai_illustration"
        )
        let q1 = addQuestion(
            ctx: viewContext,
            survey: surveyAI,
            text: "Apakah kamu pakai ChatGPT?",
            type: "Multiple Choice"
        )
        let opt1_yes = addOption(ctx: viewContext, q: q1, text: "Ya, Sering")
        addOption(ctx: viewContext, q: q1, text: "Jarang")
        addOption(ctx: viewContext, q: q1, text: "Tidak Pernah")

        let q2 = addQuestion(
            ctx: viewContext,
            survey: surveyAI,
            text: "Ceritakan pengalamanmu!",
            type: "Long Answer"
        )

        // SCENARIO 2: TARGETED LOCATION (Muncul di Felicia karena Surabaya)
        // Owner: Evelin (Supaya Felicia bisa isi)
        let surveySleep = createSurvey(
            ctx: viewContext,
            owner: evelin,
            title: "Pola Tidur & Gadget",
            desc:
                "Hubungan main HP sebelum tidur dengan kualitas tidur anak muda Surabaya.",
            points: 50,
            quota: 50,
            deadline: nextWeek,
            gender: "All",
            loc: "Surabaya",
            minAge: 15,
            maxAge: 30,
            categories: [catHealth],
            img: "survey_sleep"
        )
        addQuestion(
            ctx: viewContext,
            survey: surveySleep,
            text: "Jam berapa tidur?",
            type: "Short Answer"
        )

        // SCENARIO 3: MY OWN SURVEY (Tidak boleh muncul di list 'Available' Felicia)
        // Owner: Felicia
        let surveyKantin = createSurvey(
            ctx: viewContext,
            owner: felicia,
            title: "Evaluasi Kantin UC",
            desc: "Survey kepuasan pelanggan kantin lantai 1.",
            points: 20,
            quota: 200,
            deadline: nextMonth,
            gender: "All",
            loc: "UC Apartment",
            minAge: 17,
            maxAge: 30,
            categories: [catDaily, catFood],
            img: "survey_food"
        )
        addQuestion(
            ctx: viewContext,
            survey: surveyKantin,
            text: "Makanan favorit?",
            type: "Short Answer"
        )

        // SCENARIO 4: MISMATCH DEMOGRAPHY (Tidak boleh muncul di Felicia)
        // Target: Male (Felicia Female), Jakarta (Felicia Surabaya)
        let surveyGaming = createSurvey(
            ctx: viewContext,
            owner: budi,
            title: "Komunitas Gaming Jakarta",
            desc: "Gathering pecinta Dota 2 region Jakarta.",
            points: 100,
            quota: 50,
            deadline: nextWeek,
            gender: "Male",
            loc: "Jakarta",
            minAge: 18,
            maxAge: 30,
            categories: [catGaming],
            img: "survey_ai_illustration"
        )

        // SCENARIO 5: EXPIRED (Tidak boleh muncul)
        let surveyExpired = createSurvey(
            ctx: viewContext,
            owner: budi,
            title: "Flash Sale 12.12",
            desc: "Survey cepat tanggap.",
            points: 500,
            quota: 50,
            deadline: yesterday,  // EXPIRED
            gender: "All",
            loc: "All",
            minAge: 10,
            maxAge: 60,
            categories: [catDaily],
            img: "survey_office"
        )

        // SCENARIO 6: QUOTA FULL (Tidak boleh muncul)
        // Owner: Evelin
        let surveyFull = createSurvey(
            ctx: viewContext,
            owner: evelin,
            title: "Giveaway Voucher 50k",
            desc: "Hanya untuk 1 orang tercepat.",
            points: 1000,
            quota: 1,
            deadline: nextWeek,
            gender: "All",
            loc: "All",
            minAge: 10,
            maxAge: 60,
            categories: [catDaily],
            img: "survey_office"
        )
        // Buat Andi mengisi survey ini agar kuota penuh
        fillSurvey(ctx: viewContext, survey: surveyFull, user: andi)

        // SCENARIO 7: COMPLEX DEMO (Muncul di Felicia - Universal)
        // Berisi semua tipe soal untuk showcase
        let surveyDemo = createSurvey(
            ctx: viewContext,
            owner: budi,
            title: "Survey Kepuasan Karyawan (Demo)",
            desc:
                "Demo semua tipe soal: Pilihan Ganda, Isian, Kotak Centang, Scale.",
            points: 100,
            quota: 500,
            deadline: nextMonth,
            gender: "All",
            loc: "All",
            minAge: 18,
            maxAge: 55,
            categories: [catDaily],
            img: "survey_office"
        )

        // Q1: Multiple Choice
        let qMc = addQuestion(
            ctx: viewContext,
            survey: surveyDemo,
            text: "Divisi?",
            type: "Multiple Choice"
        )
        addOption(ctx: viewContext, q: qMc, text: "IT")
        addOption(ctx: viewContext, q: qMc, text: "Marketing")

        // Q2: Check Box
        let qCheck = addQuestion(
            ctx: viewContext,
            survey: surveyDemo,
            text: "Fasilitas favorit? (Check Box)",
            type: "Check Box"
        )
        addOption(ctx: viewContext, q: qCheck, text: "Gym")
        addOption(ctx: viewContext, q: qCheck, text: "Kantin")

        // Q3: Drop Down
        let qDrop = addQuestion(
            ctx: viewContext,
            survey: surveyDemo,
            text: "Lama bekerja? (Dropdown)",
            type: "Drop Down"
        )
        addOption(ctx: viewContext, q: qDrop, text: "< 1 Tahun")
        addOption(ctx: viewContext, q: qDrop, text: "> 1 Tahun")

        // Q4: Linear Scale
        let qScale = addQuestion(
            ctx: viewContext,
            survey: surveyDemo,
            text: "Kepuasan Gaji (1-5)",
            type: "Linear Scale"
        )
        for i in 1...5 { addOption(ctx: viewContext, q: qScale, text: "\(i)") }

        // --- 4. HISTORY & TRANSACTIONS (Felicia's Data) ---

        // Felicia pernah mengisi Survey AI (Jadi masuk History, gak muncul di Available)
        let hRes = fillSurvey(ctx: viewContext, survey: surveyAI, user: felicia)

        // Isi jawaban detail (DResponse)
        let dRes1 = DResponse(context: viewContext)
        dRes1.dresponse_id = UUID()
        dRes1.in_hresponse = hRes
        dRes1.in_question = q1
        dRes1.dresponse_answer_text = "Ya, Sering"
        dRes1.has_option = NSSet(object: opt1_yes)

        let dRes2 = DResponse(context: viewContext)
        dRes2.dresponse_id = UUID()
        dRes2.in_hresponse = hRes
        dRes2.in_question = q2
        dRes2.dresponse_answer_text = "Sangat membantu coding."

        // Transaction History Felicia
        createTransaction(
            ctx: viewContext,
            user: felicia,
            amount: 1000,
            desc: "Top Up Berhasil",
            type: "TOP UP",
            date: calendar.date(byAdding: .day, value: -2, to: today)!
        )

        createTransaction(
            ctx: viewContext,
            user: felicia,
            amount: 50,
            desc: "Reward: Penggunaan AI",
            type: "REWARD SURVEY",
            date: yesterday,
            survey: surveyAI
        )

        createTransaction(
            ctx: viewContext,
            user: felicia,
            amount: -500,
            desc: "Withdraw to GoPay",
            type: "WITHDRAW",
            date: today
        )

        // --- SIMPAN ---
        do {
            try viewContext.save()
            print("✅ Seeding Berhasil! Data user & survey lengkap.")
        } catch {
            print("❌ Gagal menyimpan seeder: \(error.localizedDescription)")
        }
    }

    // MARK: - HELPER FUNCTIONS (Supaya kode rapi)

    private static func createCategory(
        ctx: NSManagedObjectContext,
        name: String
    ) -> Category {
        let cat = Category(context: ctx)
        cat.category_id = UUID()
        cat.category_name = name
        return cat
    }

    @discardableResult
    private static func createSurvey(
        ctx: NSManagedObjectContext,
        owner: User,
        title: String,
        desc: String,
        points: Int,
        quota: Int,
        deadline: Date?,
        gender: String,
        loc: String,
        minAge: Int,
        maxAge: Int,
        categories: [Category],
        img: String
    ) -> Survey {
        let s = Survey(context: ctx)
        s.survey_id = UUID()
        s.survey_title = title
        s.survey_description = desc
        s.survey_points = Int32(points * quota)  // Biaya owner
        s.survey_rewards_points = Int32(points)  // Reward user
        s.survey_target_responden = Int32(quota)
        s.survey_deadline = deadline
        s.survey_gender = gender
        s.survey_residence = loc
        s.survey_usia_min = Int32(minAge)
        s.survey_usia_max = Int32(maxAge)
        s.survey_img_url = img
        s.is_public = true
        s.survey_status_del = false
        s.survey_created_at = Date()
        s.survey_updated_at = Date()
        s.owned_by_user = owner

        for cat in categories {
            s.addToHas_category(cat)
        }
        return s
    }
    @discardableResult
        private static func addQuestion(
            ctx: NSManagedObjectContext,
            survey: Survey,
            text: String,
            type: String
        ) -> Question {
            let q = Question(context: ctx)
            q.question_id = UUID()
            q.question_text = text
            q.question_type = type
            q.question_price = 10
            q.question_status_del = false
            q.in_survey = survey
            
            let existingCount = survey.has_question?.count ?? 0
            q.question_created_at = Date().addingTimeInterval(Double(existingCount))
            
            return q
        }

    @discardableResult
    private static func addOption(
        ctx: NSManagedObjectContext,
        q: Question,
        text: String
    ) -> Option {
        let o = Option(context: ctx)
        o.option_id = UUID()
        o.option_text = text
        o.in_question = q
        return o
    }

    @discardableResult
    private static func fillSurvey(
        ctx: NSManagedObjectContext,
        survey: Survey,
        user: User
    ) -> HResponse {
        let h = HResponse(context: ctx)
        h.hresponse_id = UUID()
        h.submitted_at = Date()
        h.in_survey = survey
        h.is_filled_by_user = user
        return h
    }

    private static func createTransaction(
        ctx: NSManagedObjectContext,
        user: User,
        amount: Int,
        desc: String,
        type: String,
        date: Date,
        survey: Survey? = nil
    ) {
        let t = Transaction(context: ctx)
        t.transaction_id = UUID()
        t.transaction_point_change = Int32(amount)
        t.transaction_description = desc
        t.transaction_type = type
        t.transaction_created_at = date
        t.transaction_status_del = false
        t.owned_by_user = user
        if let s = survey { t.in_survey = s }
    }
}
