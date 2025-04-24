import mongoose from "mongoose";


const userSchema = new mongoose.Schema(
    {
        user_name:{
            type:String,
            unique:true,
            required:true,
            trim:true,
            index:true,
        }, 
        email:{
            type:String,
            unique:true,
            required:true,
            trim:true,
        },
        password:{
            type:String,
            required:true,
        },
        avatar_url:{
            type:String,
            required:true,
            default:"https://www.gravatar.com/avatar/"
        },
        some_array:[
            {
                type:mongoose.Schema.Types.ObjectId,
                ref:"SubTodo"
            }
        ],
        someStatus:{
            type:String,
            enum:['PENDING','COMPLETED','CANCELLED'],
            default:'PENDING'
       },
       refresh_token:{
        type:String
       }
    },{timestamps:true}
);

export const User=mongoose.model("User",userSchema);