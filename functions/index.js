const functions = require("firebase-functions");
const admin=require("firebase-admin");
admin.initializeApp();

exports.takipGerceklesti= functions.firestore.document('takipciler/{takipEdilenId}/KullanicininTakipcileri/{takipEdenKullaniciId}').onCreate(async(snapshot, context)=>{
    const takipEdilenId=context.params.takipEdilenId;
    const takipEdenId=context.params.takipEdenKullaniciId;

    const yazilarSnapshot=await admin.firestore().collection("yazilar").doc(takipEdilenId).collection("kullaniciYazilari").get();
   

    yazilarSnapshot.forEach((doc)=>{
       if(doc.exists){
        const yaziId=doc.id;
        const yaziData=doc.data();

        admin.firestore().collection("akislar").doc(takipEdenId).collection("kullaniciAkisGonderileri").doc(yaziId).set(yaziData);
       }
       
     
    });

   
   

    });


exports.takipGerceklestii= functions.firestore.document('takipciler/{takipEdilenId}/KullanicininTakipcileri/{takipEdenKullaniciId}').onCreate(async(snapshot, context)=>{
        const takipEdilenId=context.params.takipEdilenId;
        const takipEdenId=context.params.takipEdenKullaniciId;
    
       
        const gonderilerSnapshot=await admin.firestore().collection("gonderiler").doc(takipEdilenId).collection("kullaniciniGonderileri").get();
    
       
    
        gonderilerSnapshot.forEach((doc)=>{
           if(doc.exists){
            const gonderiId=doc.id;
            const gonderiData=doc.data();
    
            admin.firestore().collection("gonderiAkislari").doc(takipEdenId).collection("kullaniciAkisFotolari").doc(gonderiId).set(gonderiData);

           }
           
          
        });
       
    
        });

exports.takiptenCikildi= functions.firestore.document('takipciler/{takipEdilenId}/KullanicininTakipcileri/{takipEdenKullaniciId}').onDelete(async(snapshot, context)=>{
        const takipEdilenId=context.params.takipEdilenId;
        const takipEdenId=context.params.takipEdenKullaniciId;
        
           
        const gonderilerSnapshot=await admin.firestore().collection("gonderiAkislar").doc(takipEdenId).collection("kullaniciAkisFotolari").where("yayinlayanId","==",takipEdilenId).get();
        
           
        
        gonderilerSnapshot.forEach((doc)=>{
            if(doc.exists){

                doc.ref.delete();

            }
           
            });
           
        
            });

exports.takiptenCikildii= functions.firestore.document('takipciler/{takipEdilenId}/KullanicininTakipcileri/{takipEdenKullaniciId}').onDelete(async(snapshot, context)=>{
    const takipEdilenId=context.params.takipEdilenId;
    const takipEdenId=context.params.takipEdenKullaniciId;
                
                   
    const yazilarSnapshot=await admin.firestore().collection("akislar").doc(takipEdenId).collection("kullaniciAkisGonderileri").where("yayinlayanId","==",takipEdilenId).get();
                
                   
                
        yazilarSnapshot.forEach((doc)=>{
            if(doc.exists){
        
                doc.ref.delete();
        
                }
                   
         });
                   
                
});


exports.yeniGonderiEklendi=functions.firestore.document('gonderiler/{takipEdilenKullaniciId}/kullaniciniGonderileri/{gonderiId}').onCreate(async(snapshot,context)=>{

  const takipEdilenId=context.params.takipEdilenKullaniciId;
  const gonderiId=context.params.gonderiId;

  const yeniGonderiData= snapshot.data();

const takipcilerSnapshot=await  admin.firestore().collection("takipciler").doc(takipEdilenId).collection("KullanicininTakipcileri").get();

takipcilerSnapshot.forEach(doc=>{
    const takipciId=doc.id;

    admin.firestore().collection("gonderiAkislari").doc(takipciId).collection("kullaniciAkisFotolari").doc(gonderiId).set(yeniGonderiData);

});



});

exports.yeniYaziEklendi=functions.firestore.document('yazilar/{takipEdilenKullaniciId}/kullaniciYazilari/{yaziiId}').onCreate(async(snapshot,context)=>{

    const takipEdilenId=context.params.takipEdilenKullaniciId;
    const yaziId=context.params.yaziiId;
  
    const yeniYaziData= snapshot.data();
  
  const takipcilerSnapshot=await  admin.firestore().collection("takipciler").doc(takipEdilenId).collection("KullanicininTakipcileri").get();
  
  takipcilerSnapshot.forEach(doc=>{
      const takipciId=doc.id;
  
      admin.firestore().collection("akislar").doc(takipciId).collection("kullaniciAkisGonderileri").doc(yaziId).set(yeniYaziData);
  
  });
  
  
  
  });


  exports.yaziGuncellendi=functions.firestore.document('yazilar/{takipEdilenKullaniciId}/kullaniciYazilari/{yaziiId}').onUpdate(async(snapshot,context)=>{

    const takipEdilenId=context.params.takipEdilenKullaniciId;
    const yaziId=context.params.yaziiId;
  
    const guncellenmisYaziData= snapshot.after.data();
  
  const takipcilerSnapshot=await  admin.firestore().collection("takipciler").doc(takipEdilenId).collection("KullanicininTakipcileri").get();
  
  takipcilerSnapshot.forEach(doc=>{
      const takipciId=doc.id;
  
      admin.firestore().collection("akislar").doc(takipciId).collection("kullaniciAkisGonderileri").doc(yaziId).update(guncellenmisYaziData);
  
  });
  
  
  
  });



  exports.gonderiGuncellendii=functions.firestore.document('gonderiler/{takipEdilenKullaniciId}/kullaniciniGonderileri/{gonderiId}').onUpdate(async(snapshot,context)=>{

    const takipEdilenId=context.params.takipEdilenKullaniciId;
    const gonderiId=context.params.gonderiId;
  
    const guncellenmisGonderiData= snapshot.after.data();
  
  const takipcilerSnapshot=await  admin.firestore().collection("takipciler").doc(takipEdilenId).collection("KullanicininTakipcileri").get();
  
  takipcilerSnapshot.forEach(doc=>{
      const takipciId=doc.id;
  
      admin.firestore().collection("gonderiAkislari").doc(takipciId).collection("kullaniciAkisFotolari").doc(gonderiId).update(guncellenmisGonderiData);
  
  });
  
  
  
  });



  exports.gonderiSilindi=functions.firestore.document('gonderiler/{takipEdilenKullaniciId}/kullaniciniGonderileri/{gonderiId}').onDelete(async(snapshot,context)=>{

    const takipEdilenId=context.params.takipEdilenKullaniciId;
    const gonderiId=context.params.gonderiId;

  const takipcilerSnapshot=await  admin.firestore().collection("takipciler").doc(takipEdilenId).collection("KullanicininTakipcileri").get();
  
  takipcilerSnapshot.forEach(doc=>{
      const takipciId=doc.id;
  
      admin.firestore().collection("gonderiAkislari").doc(takipciId).collection("kullaniciAkisFotolari").doc(gonderiId).delete();
  
  });
  
  
  
  });


  exports.yaziSilindi=functions.firestore.document('yazilar/{takipEdilenKullaniciId}/kullaniciYazilari/{yaziiId}').onDelete(async(snapshot,context)=>{

    const takipEdilenId=context.params.takipEdilenKullaniciId;
    const yaziId=context.params.yaziiId;
    const takipcilerSnapshot=await  admin.firestore().collection("takipciler").doc(takipEdilenId).collection("KullanicininTakipcileri").get();
  
  takipcilerSnapshot.forEach(doc=>{
      const takipciId=doc.id;
  
      admin.firestore().collection("akislar").doc(takipciId).collection("kullaniciAkisGonderileri").doc(yaziId).delete();
  
  });
  
  
  
  });


