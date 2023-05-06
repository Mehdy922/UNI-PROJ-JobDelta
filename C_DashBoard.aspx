﻿<%@ Page Title="" Language="C#" MasterPageFile="~/MyMaster2.Master" AutoEventWireup="true" CodeBehind="C_DashBoard.aspx.cs" Inherits="JobDelta.C_DashBoard" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="Resources/CSS/C_DashBoard.css" rel="stylesheet" />
</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

 <form action="#" runat="server">

    <br />

              <div class="wrapper"> 
    
                        <div class="sidebar"  style="border-radius:10px;">

                      <div class="container"> 
                        <h2>Profile Information</h2>
                        <div class="profile-box">
                             <asp:Image ID="ImageControl" runat="server" />
                             <h3>Name</h3>
                             <asp:Label ID="name" runat="server"></asp:Label>
                             <h3>Email</h3>
                             <asp:Label ID="email" runat="server"></asp:Label>
                             <h3>Phone</h3>
                             <asp:Label ID="phone" runat="server"></asp:Label>
                             </div>
                      </div>

                      <div class="container"> 
                        <h2>Statistics</h2>
                        <div class="stat-box">
                         <h3>Total Projects</h3>
                            <asp:Label ID="totalProjects" runat="server" ></asp:Label>
                            <h3>Active Projects</h3>
                            <asp:Label ID="activeProjects" runat="server" ></asp:Label>
                            <h3>Completed Projects</h3>
                            <asp:Label ID="completedProjects" runat="server" ></asp:Label>
                            <h3>Total Spendings</h3>
                            $<asp:Label ID="totalSpendings" runat="server" ></asp:Label>
                        </div>
                      </div>

                      <div class="container"> 
                        <h2>Extra Information</h2>
                        <div class="extra_stat-box">
                          <h3>Active Project Posts</h3>
                            <asp:Label ID="activeProjectPosts" runat="server"></asp:Label>
                            <h3>Rating Received</h3>
                            <asp:Label ID="feedbackReceived" runat="server"></asp:Label> out of 5
                        </div>
                      </div>
                        <div style="display: flex; justify-content: center; align-items: center;"><button onclick="redirect()" class="sp_button">Chat</button></div>


                    </div>


            <section class="content" style="margin-left:20px;">
               <br />
                 <div style="-webkit-font-smoothing:antialiased; font-size:30px; margin-left:20px "><strong>My Postings</strong></div>
               <br />
                <br />
                        <div style="margin-left:42%;">
                       <button class="sp_button" onclick="openPostJob()">Post New Job</button>
                      </div>
                            <br />

                <!-- The popup container -->
                        <div class="popup-container">
                          <!-- The popup content -->
                          <div class="popup-content">
                            <h2>Post a New Job</h2>

                            <label class="popup-label" for="job-title">Job Title:</label>
                            <input class="popup-input" type="text" id="job-title" name="job-title" required>
                            <br>

                            <label class="popup-label" for="job-description">Job Description:</label>
                            <textarea class="popup-input" style="width:450px; height:72px;" id="job-description" name="job-description" rows="4" required></textarea>
                            <br>

                            <label class="popup-label" for="job-category">Job Category:</label>
                            <select class="popup-input" id="job-category" name="job-category" required>
                              <option value="">Select a category</option>
                              <option value="web-design">Web Design</option>
                              <option value="graphic-design">Graphic Design</option>
                              <option value="software-development">Software Development</option>
                              <!-- Add more options here -->
                            </select>
                            <br>

                            <label class="popup-label" for="job-budget">Budget:</label>
                            <input class="popup-input" type="number" id="job-budget" name="job-budget" required>
                            <br>

       
                              <!-- Add more options here -->
                
                            <br>

                            <label class="popup-label" for="job-skills">Skills Required:</label>
                            <input class="popup-input" type="text" id="job-skills" name="job-skills">
                            <br>


                            <button class="sp_button" type="submit">Post Job</button>

                            <!-- Close button for the popup -->
                            <button class="close-button">&times;</button>
                          </div>
                        </div>

               <asp:GridView ID="PostingGridView" runat="server" AutoGenerateColumns="False" OnRowCommand="PostingGridView_RowCommand" CssClass="table">
                <Columns>
                    <asp:BoundField DataField="PostingID" HeaderText="Posting ID" />
                    <asp:BoundField DataField="Title" HeaderText="Title" />
                    <asp:BoundField DataField="Description" HeaderText="Description" />
                    <asp:BoundField DataField="Category" HeaderText="Category" />
                    <asp:BoundField DataField="Budget" HeaderText="Budget" />
                    <asp:BoundField DataField="JobStatus" HeaderText="Job Status" />
                    <asp:TemplateField HeaderText="Edit">
                        <ItemTemplate>
                            <asp:LinkButton CssClass="sp_button" ID="lnkEdit" runat="server" Text="Edit" CommandName="Edit" CommandArgument='<%# Eval("PostingID") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>        
            </asp:GridView>


                  <section class="Banner">
                  <h2>Unlock Your Potential on Job Delta</h2>
                  <p>Are you ready to take your career to the next level? Follow these three steps to become a top performer on Job Delta:</p>
                  <ul>
                    <li class="B_container">
                      <h3>Find Your Dream Job</h3>
                      <p>Our platform has a vast selection of job opportunities across various industries. Don't settle for a job you don't love. Explore our job listings and find your perfect match.</p>
                    </li>
                    <li class="B_container">
                      <h3>Sharpen Your Skills</h3>
                      <p>Stay competitive and up-to-date with the latest industry trends by taking advantage of our training resources. Our expert-led courses and webinars cover everything from technical skills to soft skills.</p>
                    </li>
                    <li class="B_container">
                      <h3>Become a Standout Candidate</h3>
                      <p>Make a lasting impression on potential employers by making a standout profile on Job Delta. Showcase your skills, accomplishments, and personality to make a great first impression.</p>
                      <a href="MyProfile.aspx">Edit Profile Now</a>
                    </li>
                  </ul>
                </section>
     </section>

</div>

    <%-------------------------------------------------------------------------------------------------%> 
 
         <div class="slide2show-container"> 
              <div class="slide2">
                <img src="https://source.unsplash.com/random/800x400" alt="Slide 1">
                <div class="slide2-text">
                  <h2>Welcome to Job Delta</h2>
                  <p>We are a freelancing platform connecting businesses with top-rated freelancers from around the world. Our mission is to help businesses grow and succeed by providing them with the best freelance talent available.</p>
                </div>
              </div>
              <div class="slide2">
                <img src="https://source.unsplash.com/random/800x400" alt="Slide 2">
                <div class="slide2-text">
                  <h2>Hire Top Freelancers</h2>
                  <p>Find the perfect freelancer for your project. Our platform offers a wide range of freelancers with diverse skills and experience levels, so you can find the right fit for your project.</p>
                </div>
              </div>
              <div class="slide2">
                <img src="https://source.unsplash.com/random/800x400" alt="Slide 3">
                <div class="slide2-text">
                  <h2>Grow Your Business</h2>
                  <p>Get the help you need to grow your business. Our freelancers offer a wide range of services, from web development and design to marketing and content creation, to help your business succeed.</p>
                </div>
              </div>
            </div>

<%-------------------------------------------------------------------------------------------------%> 
     </form>

    <script src="Resources/JavaScript/C_Dashboard.js"></script>
    <script src="Resources/JavaScript/chatApp.js"></script>
</asp:Content>
