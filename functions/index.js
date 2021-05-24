const functions = require("firebase-functions");
const admin=require("firebase-admin");
admin.initializeApp();

exports.takipGerceklesti= functions.firestore.document('takipciler/{takipEdilenId}/kullanicininTakipcileri/{takipEdenKullaniciId}').onCreate(async(snapshot, context)=>{
    const takipEdilenId=context.params.takipEdilenId;
    const takipEdenId=context.params.takiEdenKullaniciId;

    console.log(takipEdenId);
    console.log(takipEdilenId);


   admin.firestore().collection("deneme").add("deneme");
 


}); 
  
