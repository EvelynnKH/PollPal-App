//
//  DataSeeder.swift
//  PollPal
//
//  Created by student on 03/12/25.
//

import CoreData
import Foundation

struct DataSeeder {
    static func seed(viewContext: NSManagedObjectContext) {
        // 1. Cek apakah database sudah ada isinya?
        if isDatabaseEmpty(viewContext: viewContext) {
            print("Database kosong. Memulai seeding data...")
            createData(viewContext: viewContext)
        } else {
            print("Data sudah ada. Skip seeding.")
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
            return true  // Jika error, anggap kosong biar aman
        }
    }

    private static func createData(viewContext: NSManagedObjectContext) {

       

        //Category
        let catTech = Category(context: viewContext)
        catTech.category_id = UUID()
        catTech.category_name = "Technology"

        let catDaily = Category(context: viewContext)
        catDaily.category_id = UUID()
        catDaily.category_name = "Daily Life"

        let catHealth = Category(context: viewContext)
        catHealth.category_id = UUID()
        catHealth.category_name = "Health"
        
        //user
        let felicia = User(context: viewContext)
        felicia.user_id = UUID()
        felicia.user_name = "Felicia Kathrin"
        felicia.user_email = "feli@gmail.com"
        felicia.user_pwd = "feli123"
        felicia.user_point = 100
        felicia.user_header_img = "mountain"
        felicia.user_profile_img = "cat"
        felicia.user_created_at = Date()
        felicia.user_status_del = false
        
        felicia.addToLike_category(catTech)
        felicia.addToLike_category(catDaily)

        //Survey
        // 1. Survey Tech
        let survey1 = Survey(context: viewContext)
        survey1.survey_id = UUID()
        survey1.survey_title = "Penggunaan AI Mahasiswa"
        survey1.survey_description =
            "Seberapa sering mahasiswa menggunakan ChatGPT untuk tugas?"
        survey1.survey_points = 50
        survey1.survey_rewards_points = 250
        survey1.survey_created_at = Date()
        survey1.is_public = true
        survey1.survey_updated_at = Date()
        survey1.survey_status_del = false
        survey1.owned_by_user = felicia

        // Relasi Category (Many-to-Many)
        survey1.addToHas_category(catTech)

        // Tambah Dummy Question (Biar estimasi waktu muncul)
        let q1 = Question(context: viewContext)
        q1.question_id = UUID()
        q1.quetion_text = "Apakah kamu pakai ChatGPT?"
        q1.question_type = "Multiple Choice"
        q1.question_price = 10
        q1.question_status_del = false
        q1.in_survey = survey1

        //option
        let opt1_yes = addOption(
            to: q1,
            text: "Ya, Sering",
            context: viewContext
        )
        let opt1_no = addOption(
            to: q1,
            text: "Tidak Pernah",
            context: viewContext
        )

        let q2 = Question(context: viewContext)
        q2.question_id = UUID()
        q2.quetion_text = "Ceritakan pengalamanmu!"
        q2.question_type = "Long Answer"
        q2.question_price = 10
        q2.question_status_del = false
        q2.in_survey = survey1

        let q3 = Question(context: viewContext)
        q3.question_id = UUID()
        q3.quetion_text = "Apakah kamu pakai ChatGPT?"
        q3.question_type = "Multiple Choice"
        q3.question_price = 10
        q3.question_status_del = false
        q3.in_survey = survey1

        // 2. Survey Health (Campuran Kategori)
        let survey2 = Survey(context: viewContext)
        survey2.survey_id = UUID()
        survey2.survey_title = "Pola Tidur & Gadget"
        survey2.survey_description =
            "Hubungan main HP sebelum tidur dengan kualitas tidur."
        survey2.survey_points = 50
        survey2.survey_rewards_points = 250
        survey2.survey_created_at = Date()
        survey2.is_public = true
        survey2.survey_updated_at = Date()
        survey2.survey_status_del = false
        survey2.owned_by_user = felicia

        survey2.addToHas_category(catHealth)
        survey2.addToHas_category(catTech)  // Multi kategori

        let q4 = Question(context: viewContext)
        q4.question_id = UUID()
        q4.quetion_text = "Jam berapa kamu tidur?"
        q4.question_type = "Multiple Choice"
        q4.question_price = 10
        q4.question_status_del = false
        q4.in_survey = survey2

        addOption(to: q4, text: "< 10 Malam", context: viewContext)
        addOption(to: q4, text: "> 12 Malam", context: viewContext)

        let q5 = Question(context: viewContext)
        q5.question_id = UUID()
        q5.quetion_text = "Apakah main HP di kasur?"
        q5.question_type = "Multiple Choice"
        q5.question_price = 10
        q5.question_status_del = false
        q5.in_survey = survey2

        // survey 3
        let survey3 = Survey(context: viewContext)
        survey3.survey_id = UUID()
        survey3.survey_title = "Evaluasi Kantin UC"
        survey3.survey_description = "Survey kepuasan pelanggan kantin lantai 1"
        survey3.survey_points = 50
        survey3.survey_rewards_points = 20
        survey3.is_public = true
        survey3.survey_created_at = Date()
        survey3.survey_updated_at = Date()
        survey3.survey_status_del = false
        survey3.owned_by_user = felicia  // Relasi: Milik Felicia

        survey3.addToHas_category(catDaily)

        // Question
        let q6 = Question(context: viewContext)
        q6.question_id = UUID()
        q6.quetion_text = "Apakah kamu setuju makanannya enak?"
        q6.question_type = "Short Answer"
        q6.question_price = 1
        q6.question_status_del = false
        q6.in_survey = survey1

        //hresponse, dresponse
        let hRes = HResponse(context: viewContext)
        hRes.hresponse_id = UUID()
        hRes.submitted_at = Date()
        hRes.in_survey = survey1
        hRes.is_filled_by_user = felicia

        let dRes1 = DResponse(context: viewContext)
        dRes1.dresponse_id = UUID()
        dRes1.in_hresponse = hRes  // Link ke Header
        dRes1.in_question = q1  // Link ke Pertanyaan
        dRes1.has_option = opt1_yes  // Link ke Opsi yang dipilih
        dRes1.dresponse_answer_text = opt1_yes.option_text  // Simpan text juga

        let dRes2 = DResponse(context: viewContext)
        dRes2.dresponse_id = UUID()
        dRes2.in_hresponse = hRes
        dRes2.in_question = q2
        dRes2.dresponse_answer_text = "Sangat membantu tugas coding saya."  // Isi manual essay

        //transaction
        let trans = Transaction(context: viewContext)
        trans.transaction_id = UUID()
        trans.transaction_point_change = 150  // Poin nambah
        trans.transaction_description = "Reward: Penggunaan AI Mahasiswa"
        trans.transaction_status_del = false
        trans.owned_by_user = felicia  // Link ke User
        trans.in_survey = survey1  // Link sumber poin dari survey mana

        //simpan
        do {
            try viewContext.save()
            print("✅ Seeding Berhasil Disimpan!")
        } catch {
            print("❌ Gagal menyimpan seeder: \(error.localizedDescription)")
        }
    }

    @discardableResult
    private static func addOption(
        to question: Question,
        text: String,
        context: NSManagedObjectContext
    ) -> Option {
        let opt = Option(context: context)
        opt.option_id = UUID()
        opt.option_text = text
        // Relasi ke Question (Pastikan relationship 'has_option' di core data tipe To Many)
        question.addToHas_option(opt)
        return opt
    }
}
