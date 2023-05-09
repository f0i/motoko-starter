import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";

import Type "Types";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

actor class Homework() {
  type Homework = Type.Homework;
  type Buffer<T> = Buffer.Buffer<T>;

  var homeworks : Buffer<Homework> = Buffer.Buffer<Homework>(10);

  public shared func addHomework(homework : Homework) : async Nat {
    homeworks.add(homework);
    return homeworks.size() - 1;
  };

  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    switch (homeworks.getOpt(id)) {
      case (?value) { #ok(value) };
      case (null) { #err("Invalid ID") };
    };
  };

  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
    if (id >= homeworks.size()) { return #err("Invalid ID") };
    homeworks.put(id, homework);
    return #ok;
  };

  public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
    if (id >= homeworks.size()) { return #err("Invalid ID") };
    ignore homeworks.remove(id);
    return #ok;
  };

  public shared query func getAllHomework() : async [Homework] {
    return Buffer.toArray(homeworks);
  };

  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    if (id >= homeworks.size()) { return #err("Invalid ID") };
    let h = homeworks.get(id);
    homeworks.put(
      id,
      {
        title = h.title;
        description = h.description;
        dueDate = h.dueDate;
        completed = true;
      },
    );
    return #ok;
  };

  public shared query func getPendingHomework() : async [Homework] {
    let iter = homeworks.vals();
    let filtered = Iter.filter<Homework>(iter, func(h : Homework) : Bool = not h.completed);
    return Iter.toArray(filtered);
  };

  public shared query func searchHomework(searchTerm : Text) : async [Homework] {
    let iter = homeworks.vals();
    let filtered = Iter.filter<Homework>(
      iter,
      func(h : Homework) : Bool {
        Text.contains(h.title, #text searchTerm) or Text.contains(h.description, #text searchTerm);
      },
    );
    return Iter.toArray(filtered);
  };
};
