import { asyncHandler } from "../Utils/_03_asyncHandler.utils.js";
import {ApiError} from "../Utils/_04_Api_Error.utils.js"
import {User} from "../models/_01_user.model.js"
import { uploadOnCloudinary } from "../Utils/_06_cloudinary.file_uploading.util.js";
import { ApiResponse } from "../Utils/_05_Api_Response.utils.js";

/*
user schema:
 userName: {
            type: String,
            required: true,
            unique: true,
            lowercase: true,
            trim: true, 
            index: true
        },
        email: {
            type: String,
            required: true,
            unique: true,
            lowecase: true,
            trim: true, 
        },
        fullName: {
            type: String,
            required: true,
            trim: true, 
            index: true
        },
        avatar: {
            type: String, // cloudinary url
            required: true,
        },
        coverImage: {
            type: String, // cloudinary url
        },
        watchHistory: [
            {
                type: Schema.Types.ObjectId,
                ref: "Video"
            }
        ],
        password: {
            type: String,
            required: [true, 'Password is required']
        },
        refreshToken: {
            type: String
        }
*/

const registerUser=asyncHandler(
    //steps: getAsJson->validate->checkIfAlreadyExists->ifNotThenTakeAvatar->UploadToCLpudinary->PutInMongoose
    async(req,res)=>{
        
        //step0: upload avatar, done as middleware
        
        const {userName,fullName,email,password}=req.body;
        console.log(`recived body for post method register: ${JSON.stringify(req.body)}`);

        //step1: validate if feilds r not empty
        if(
            [userName,fullName,email,password]
            .some(
                (each)=>e?.trim() === ""
            )
        ){
            throw new ApiError(400,"Username/Fullname/Email/Password cannot be empty !");
        }

        //now fields r valid
        //step2: check if user already exists in DB
        const userAlreadyExists=User.findOne(
            {
                $or:[userName,email] //checks if userName or email already exists
            }
        )
        if(userAlreadyExists){
            throw new ApiError(400,"Username/Email already exists!");
        }
        //now user is not present in DB

        //multer has now added file in req.body, lets access it to register user
        //step3: upload avatar to clodinary
        const avatarImgLocalPath=req.files?.avatar[0]?.path
        const coverImgLocalPath=req.files?.coverImage[0]?.path
        console.log(`paths received from multer:\n avatar:${avatarImgLocalPath} \n coverImage:${coverImgLocalPath}`);

        //check if files r not null
        if(!avatarImgLocalPath) throw new ApiError(400,"Avatar Image is required!")
        const avatarUploaded=await uploadOnCloudinary(avatarImgLocalPath)
        const coverImgUploaded=await uploadOnCloudinary(coverImgLocalPath)
        if(!avatarUploaded) throw new ApiError(400,"Failed to upload avatar Image!")

        //now files r uploaded to cloudinary
        //step4: all things r goin good, register user into database

        const userCreatedInDB=await User.create(
            {
                avatar:avatarUploaded.url,
                coverImage:coverImgUploaded?.url || "",
                fullName:fullName,
                userName:userName.toLowerCase(),
                email:email,
                password:password,

            }
        )
        

        //check if user created is successfulll, by finding generated id
        const user=await User.findById(
            userCreatedInDB._id
        ).select(
            "-password -refreshToken"  //try selecting all feilds except password and refreshToken
        )

        if(!user){
            throw new ApiError(400,"Failed to register user!")
        }


        //send success reponse

        return res
        .send(200)
        .json(
            new ApiResponse(
                200,
                user,
                `User created succeesfully: User: ${JSON.stringify(user)}`
            )
        )

        // res
        // .status(200)
        // .send();
    }
);

export {registerUser}