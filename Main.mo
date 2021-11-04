import Trie "mo:base/Trie";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Array "mo:base/Array";
import D "mo:base/Debug";

actor Avatar {
   public type Student_Data  = {
        name : Text;
        age : Int;
        school : [Text];
    };     
   

   public type Profile = {
        data : Student_Data;
    };

    type Error = {
        #NotFound;
        #AlreadyExists;
    };
    
     stable var profiles : Trie.Trie<Nat,Profile> = Trie.empty();// stable variable used for storing data between different states

    stable var next : Nat = 1;// counter used to check session.(stable vaiable)

    //create function
    public func create(profile : Profile) : async Result.Result<(), Error>{
        let profileId = next;
         next += 1;
         
         let (newprofile , existingprofile) = Trie.put(
            profiles ,
            key(profileId),
            Nat.equal,// == checking in existing storage for match
            profile
         );//just checking if exist putting in newprofile otherwise existingprofile

         switch(existingprofile)
         {
             case null { 
             profiles := newprofile;
             #ok(());
            };// here we are putting data into profiles Trie
            case (? v){
            #err(#AlreadyExists);
            };// if variable has something that means error is there
         }
    };
    // read function
    public func read (profileId : Nat) : async Result.Result<Profile, Error> {
        let result = Trie.find(
            profiles,
            key(profileId),
            Nat.equal
        );// will just find the match
      return Result.fromOption(result, #NotFound);
    };

     // Update profile
    public func update (profileId : Nat, profile : Profile) : async Result.Result<(), Error> {
        let result = Trie.find(
            profiles,           //Target Trie
            key(profileId),     // Key
            Nat.equal           // Equality Checker
        );

        switch (result){
           
            case null {
                #err(#NotFound)
            };// on no profile found
            case (? v) {
                profiles := Trie.replace(
                    profiles,           
                    key(profileId),     
                    Nat.equal,          
                    ?profile
                ).0;  // returns tupple of(new,existing) so we are taking new form that and putting into profile Trie
                #ok(());
            };
        };
    };

    // delete function
    public func delete (profileId : Nat) : async Result.Result<(), Error> {
        let result = Trie.find(
            profiles,           
            key(profileId),    
            Nat.equal           
        );

        switch (result){
            case null {
                #err(#NotFound);
            };// on no profile found
            case (? v) {
                profiles := Trie.replace(
                    profiles,           
                    key(profileId),     
                    Nat.equal,         
                    null
                ).0;// like update but just replacing by null in profiles Trie
                #ok(());
            };
        };
    };
   

   // function for key security , also will convert in Trie key value pair 
    private func key(x : Nat) : Trie.Key<Nat> {
        return { key = x; hash = Hash.hash(x) }
    };

    public func AppendOnArray(profileId: Nat,modifiedSchool : [Text]): async Result.Result<(), Error> {
             var result = Trie.find(
            profiles,           
            key(profileId),    
            Nat.equal           
        );
          
        switch (result){
            case null {
                #err(#NotFound);
            };// on no profile found
            case (?exists) {
                
             //   let x = Profile.Student_Data.name;
                  var a: [Text] = [];
                a := Array.append(exists.data.school, modifiedSchool);
             var dummy_studentData : Student_Data = {
                   name = exists.data.name;
                   age = exists.data.age;
                   school = a;        
            };
            var dummy_profile : Profile = {
                    data = dummy_studentData;
            };
        
                 profiles := Trie.replace(
                    profiles,           
                    key(profileId),     
                    Nat.equal,          
                    ?dummy_profile,
                ).0;
           //  D.print(profiles.school);
               // Array.append(arr,modifiedSchool);
              //  Student_Data[school].append(modifiedSchool);
             //   Array.append(Array.make(arr), arr);
                #ok(());
            };
        };
    };
}