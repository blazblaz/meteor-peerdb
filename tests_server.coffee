Persons = new Meteor.Collection 'Persons', transform: (doc) => new Person doc
Posts = new Meteor.Collection 'Posts', transform: (doc) => new Post doc

class Person extends Document
  # Other fields:
  #   username
  #   displayName

  @Meta
    collection: Persons

class Post extends Document
  # Other fields:
  #   body

  @Meta
    collection: Posts
    fields:
      author: @Reference Persons, ['username']
      subscribers: [@Reference Persons]
      reviewers: [@Reference Persons, ['username']]

Tinytest.add 'meteor-peerdb - server', (test) ->
  test.equal Person.Meta.collection, Persons
  test.equal Person.Meta.fields, {}
  test.equal Post.Meta.collection, Posts
  test.instanceOf Post.Meta.fields.author, Person._Reference
  test.isFalse Post.Meta.fields.author.isList
  test.equal Post.Meta.fields.author.sourceField, 'author'
  test.equal Post.Meta.fields.author.sourceCollection, Posts
  test.equal Post.Meta.fields.author.targetCollection, Persons
  test.equal Post.Meta.fields.author.fields, ['username']
  test.instanceOf Post.Meta.fields.subscribers, Person._Reference
  test.isTrue Post.Meta.fields.subscribers.isList
  test.equal Post.Meta.fields.subscribers.sourceField, 'subscribers'
  test.equal Post.Meta.fields.subscribers.sourceCollection, Posts
  test.equal Post.Meta.fields.subscribers.targetCollection, Persons
  test.equal Post.Meta.fields.subscribers.fields, []
  test.isTrue Post.Meta.fields.reviewers.isList
  test.equal Post.Meta.fields.reviewers.sourceField, 'reviewers'
  test.equal Post.Meta.fields.reviewers.sourceCollection, Posts
  test.equal Post.Meta.fields.reviewers.targetCollection, Persons
  test.equal Post.Meta.fields.reviewers.fields, ['username']

  test.equal Document.Meta.list, [Person, Post]

  person1Id = Persons.insert
    username: 'person1'
    displayName: 'Person 1'
  person2Id = Persons.insert
    username: 'person2'
    displayName: 'Person 2'
  person3Id = Persons.insert
    username: 'person3'
    displayName: 'Person 3'

  person1 = Persons.findOne person1Id
  person2 = Persons.findOne person2Id
  person3 = Persons.findOne person3Id

  test.instanceOf person1, Person
  test.equal person1.username, 'person1'
  test.equal person1.displayName, 'Person 1'
  test.instanceOf person2, Person
  test.equal person2.username, 'person2'
  test.equal person2.displayName, 'Person 2'
  test.instanceOf person3, Person
  test.equal person3.username, 'person3'
  test.equal person3.displayName, 'Person 3'

  postId = Posts.insert
    author:
      _id: person1._id
    subscribers: [
      _id: person2._id
    ,
      _id: person3._id
    ]
    reviewers: [
      _id: person2._id
    ,
      _id: person3._id
    ]

  # TODO: Wait and test auto-population of all fields
  # TODO: Test that only specified field were auto-populated

  Persons.update person1Id,
    $set:
      username: 'person1a'
  Persons.update person2Id,
    $set:
      username: 'person2a'
  Persons.update person3Id,
    $set:
      username: 'person3a'

  person1 = Persons.findOne person1Id
  person2 = Persons.findOne person2Id
  person3 = Persons.findOne person3Id

  test.instanceOf person1, Person
  test.equal person1.username, 'person1a'
  test.equal person1.displayName, 'Person 1'
  test.instanceOf person2, Person
  test.equal person2.username, 'person2a'
  test.equal person2.displayName, 'Person 2'
  test.instanceOf person3, Person
  test.equal person3.username, 'person3a'
  test.equal person3.displayName, 'Person 3'

  # TODO: Wait and test that usernames changed
  # TODO: Test that only usernames changed

  # TODO: Test removal of the field
  # TODO: Test removal of the object referenced from the list
  # TODO: Test removal of the object referenced directly
